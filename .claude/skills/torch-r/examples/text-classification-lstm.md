# Text Classification with LSTM - torch for R

Complete example of building a text classifier using LSTM/GRU networks in torch for R.

## Problem

Classify text documents into categories (e.g., sentiment analysis, topic classification, spam detection).

## Architecture

- Embedding layer (word → vector)
- Bidirectional LSTM
- Attention mechanism (optional)
- Classification head

## Complete Implementation

```r
library(torch)
library(tokenizers)
library(coro)

# ============================================================================
# Part 1: Text Preprocessing & Vocabulary
# ============================================================================

#' Build vocabulary from text corpus
#'
#' @param texts Character vector of documents
#' @param max_vocab_size Maximum vocabulary size
#' @param min_freq Minimum word frequency to include
#'
#' @return List with vocab (word -> id) and id2word (id -> word)
build_vocabulary <- function(texts, max_vocab_size = 10000, min_freq = 2) {
  # Tokenize all texts
  tokens_list <- tokenize_words(tolower(texts))

  # Count word frequencies
  word_counts <- table(unlist(tokens_list))
  word_counts <- sort(word_counts, decreasing = TRUE)

  # Filter by frequency
  word_counts <- word_counts[word_counts >= min_freq]

  # Limit vocabulary size
  if (length(word_counts) > max_vocab_size - 2) {
    word_counts <- head(word_counts, max_vocab_size - 2)
  }

  # Create vocabulary (reserve 1 for <PAD>, 2 for <UNK>)
  vocab <- as.list(seq_along(word_counts) + 2)
  names(vocab) <- names(word_counts)
  vocab <- c(list("<PAD>" = 1, "<UNK>" = 2), vocab)

  # Reverse mapping
  id2word <- names(vocab)
  names(id2word) <- as.character(vocab)

  list(
    vocab = vocab,
    id2word = id2word,
    vocab_size = length(vocab)
  )
}

#' Convert text to sequence of token IDs
#'
#' @param text Character vector (single document or batch)
#' @param vocab Vocabulary list (from build_vocabulary)
#' @param max_length Maximum sequence length (will pad/truncate)
#'
#' @return Integer matrix [num_texts, max_length]
texts_to_sequences <- function(texts, vocab, max_length = 100) {
  # Tokenize
  tokens_list <- tokenize_words(tolower(texts))

  # Convert to IDs
  unk_id <- vocab[["<UNK>"]]
  sequences <- lapply(tokens_list, function(tokens) {
    ids <- sapply(tokens, function(token) {
      if (token %in% names(vocab)) {
        vocab[[token]]
      } else {
        unk_id
      }
    })
    ids
  })

  # Pad/truncate to max_length
  pad_id <- vocab[["<PAD>"]]
  padded <- t(sapply(sequences, function(seq) {
    if (length(seq) > max_length) {
      seq[1:max_length]
    } else if (length(seq) < max_length) {
      c(seq, rep(pad_id, max_length - length(seq)))
    } else {
      seq
    }
  }))

  return(padded)
}

# ============================================================================
# Part 2: Text Classification Dataset
# ============================================================================

text_classification_dataset <- dataset(
  name = "TextClassificationDataset",

  initialize = function(texts, labels, vocab, max_length = 100) {
    # Convert texts to sequences
    self$sequences <- texts_to_sequences(texts, vocab, max_length)
    self$labels <- torch_tensor(labels, dtype = torch_long())
  },

  .getitem = function(i) {
    list(
      sequence = torch_tensor(self$sequences[i, ], dtype = torch_long()),
      label = self$labels[i]
    )
  },

  .length = function() {
    nrow(self$sequences)
  }
)

# ============================================================================
# Part 3: LSTM Text Classifier with Attention
# ============================================================================

lstm_text_classifier <- nn_module(
  name = "LSTMTextClassifier",

  initialize = function(vocab_size, embedding_dim = 128, hidden_dim = 256,
                        num_classes = 2, num_layers = 2,
                        bidirectional = TRUE, dropout = 0.5,
                        use_attention = TRUE) {

    self$use_attention <- use_attention
    self$num_directions <- if (bidirectional) 2 else 1

    # Embedding layer
    self$embedding <- nn_embedding(
      num_embeddings = vocab_size,
      embedding_dim = embedding_dim,
      padding_idx = 1  # <PAD> token ID
    )

    # LSTM layer
    self$lstm <- nn_lstm(
      input_size = embedding_dim,
      hidden_size = hidden_dim,
      num_layers = num_layers,
      bidirectional = bidirectional,
      dropout = if (num_layers > 1) dropout else 0,
      batch_first = TRUE
    )

    # Attention layer (optional)
    if (use_attention) {
      self$attention <- nn_linear(hidden_dim * self$num_directions, 1)
    }

    # Classification head
    self$fc <- nn_linear(hidden_dim * self$num_directions, num_classes)
    self$dropout <- nn_dropout(dropout)
  },

  forward = function(x, lengths = NULL) {
    # x shape: [batch, seq_len]

    # Embedding
    embedded <- self$embedding(x)  # [batch, seq_len, embedding_dim]
    embedded <- self$dropout(embedded)

    # Pack sequence if lengths provided (for efficiency with padding)
    if (!is.null(lengths)) {
      embedded <- nn_utils_rnn_pack_padded_sequence(
        embedded,
        lengths,
        batch_first = TRUE,
        enforce_sorted = FALSE
      )
    }

    # LSTM
    lstm_out <- self$lstm(embedded)
    output <- lstm_out[[1]]  # [batch, seq_len, hidden_dim * directions]

    # Unpack if packed
    if (!is.null(lengths)) {
      output <- nn_utils_rnn_pad_packed_sequence(
        output,
        batch_first = TRUE
      )[[1]]
    }

    # Apply attention or use last hidden state
    if (self$use_attention) {
      # Attention mechanism
      # Compute attention scores for each timestep
      attention_scores <- self$attention(output)  # [batch, seq_len, 1]
      attention_scores <- attention_scores$squeeze(3)  # [batch, seq_len]

      # Softmax to get attention weights
      attention_weights <- nnf_softmax(attention_scores, dim = 2)  # [batch, seq_len]

      # Weighted sum of LSTM outputs
      attention_weights_expanded <- attention_weights$unsqueeze(3)  # [batch, seq_len, 1]
      weighted <- output * attention_weights_expanded  # [batch, seq_len, hidden_dim]
      sentence_embedding <- weighted$sum(dim = 2)  # [batch, hidden_dim]

    } else {
      # Use last timestep output
      sentence_embedding <- output[, -1, ]  # [batch, hidden_dim * directions]
    }

    # Classification
    logits <- self$fc(self$dropout(sentence_embedding))

    return(logits)
  }
)

# ============================================================================
# Part 4: Training Pipeline
# ============================================================================

#' Train text classifier
#'
#' @param train_texts Character vector of training texts
#' @param train_labels Integer vector of labels (1-indexed)
#' @param val_texts Validation texts
#' @param val_labels Validation labels
#' @param num_classes Number of output classes
#' @param vocab Vocabulary (if NULL, will build from training data)
#' @param max_length Maximum sequence length
#' @param embedding_dim Embedding dimension
#' @param hidden_dim LSTM hidden dimension
#' @param num_epochs Number of training epochs
#' @param batch_size Batch size
#' @param learning_rate Learning rate
#' @param device Device ("cuda" or "cpu")
train_text_classifier <- function(train_texts, train_labels,
                                  val_texts, val_labels,
                                  num_classes,
                                  vocab = NULL,
                                  max_length = 100,
                                  embedding_dim = 128,
                                  hidden_dim = 256,
                                  num_epochs = 20,
                                  batch_size = 32,
                                  learning_rate = 0.001,
                                  device = "cpu") {

  # Build vocabulary if not provided
  if (is.null(vocab)) {
    cat("Building vocabulary...\n")
    vocab_info <- build_vocabulary(train_texts, max_vocab_size = 10000)
    vocab <- vocab_info$vocab
    vocab_size <- vocab_info$vocab_size
    cat(sprintf("Vocabulary size: %d\n", vocab_size))
  } else {
    vocab_size <- length(vocab)
  }

  # Create datasets
  train_ds <- text_classification_dataset(
    train_texts,
    train_labels,
    vocab,
    max_length
  )

  val_ds <- text_classification_dataset(
    val_texts,
    val_labels,
    vocab,
    max_length
  )

  # Create dataloaders
  train_dl <- dataloader(
    train_ds,
    batch_size = batch_size,
    shuffle = TRUE
  )

  val_dl <- dataloader(
    val_ds,
    batch_size = batch_size,
    shuffle = FALSE
  )

  # Initialize model
  model <- lstm_text_classifier(
    vocab_size = vocab_size,
    embedding_dim = embedding_dim,
    hidden_dim = hidden_dim,
    num_classes = num_classes,
    num_layers = 2,
    bidirectional = TRUE,
    dropout = 0.5,
    use_attention = TRUE
  )
  model$to(device = device)

  # Loss and optimizer
  criterion <- nn_cross_entropy_loss()
  optimizer <- optim_adam(model$parameters, lr = learning_rate)

  # Learning rate scheduler
  scheduler <- lr_step(optimizer, step_size = 5, gamma = 0.5)

  # Training loop
  best_val_acc <- 0

  for (epoch in 1:num_epochs) {
    # ========== Training ==========
    model$train()
    train_loss <- 0
    train_correct <- 0
    train_total <- 0

    coro::loop(for (batch in train_dl) {
      sequences <- batch$sequence$to(device = device)
      labels <- batch$label$to(device = device)

      # Forward pass
      optimizer$zero_grad()
      outputs <- model(sequences)
      loss <- criterion(outputs, labels)

      # Backward pass
      loss$backward()
      nn_utils_clip_grad_norm_(model$parameters, max_norm = 5.0)  # Important for RNNs!
      optimizer$step()

      # Track metrics
      train_loss <- train_loss + loss$item()
      predictions <- outputs$argmax(dim = 2)
      train_correct <- train_correct + (predictions == labels)$sum()$item()
      train_total <- train_total + labels$size(1)
    })

    train_accuracy <- train_correct / train_total
    avg_train_loss <- train_loss / length(train_dl)

    # ========== Validation ==========
    model$eval()
    val_loss <- 0
    val_correct <- 0
    val_total <- 0

    with_no_grad({
      coro::loop(for (batch in val_dl) {
        sequences <- batch$sequence$to(device = device)
        labels <- batch$label$to(device = device)

        outputs <- model(sequences)
        loss <- criterion(outputs, labels)

        val_loss <- val_loss + loss$item()
        predictions <- outputs$argmax(dim = 2)
        val_correct <- val_correct + (predictions == labels)$sum()$item()
        val_total <- val_total + labels$size(1)
      })
    })

    val_accuracy <- val_correct / val_total
    avg_val_loss <- val_loss / length(val_dl)

    # Update learning rate
    scheduler$step()

    # Print progress
    cat(sprintf(
      "Epoch %2d/%d | Train Loss: %.4f Acc: %.2f%% | Val Loss: %.4f Acc: %.2f%%\n",
      epoch, num_epochs,
      avg_train_loss, train_accuracy * 100,
      avg_val_loss, val_accuracy * 100
    ))

    # Save best model
    if (val_accuracy > best_val_acc) {
      best_val_acc <- val_accuracy
      torch_save(
        list(model = model, vocab = vocab),
        "best_text_model.pt"
      )
      cat("  → Best model saved!\n")
    }
  }

  return(list(model = model, vocab = vocab))
}

# ============================================================================
# Part 5: Inference
# ============================================================================

#' Predict class for new text
#'
#' @param model_path Path to saved model
#' @param text Character string (single text to classify)
#' @param class_names Character vector of class names
#' @param device Device ("cuda" or "cpu")
predict_text_class <- function(model_path, text, class_names, device = "cpu") {
  # Load model and vocabulary
  checkpoint <- torch_load(model_path)
  model <- checkpoint$model
  vocab <- checkpoint$vocab

  model$to(device = device)
  model$eval()

  # Preprocess text
  # Assume max_length = 100 (should match training)
  sequence <- texts_to_sequences(text, vocab, max_length = 100)
  sequence_tensor <- torch_tensor(sequence, dtype = torch_long())$to(device = device)

  # Predict
  with_no_grad({
    output <- model(sequence_tensor)
    probs <- nnf_softmax(output, dim = 2)
    pred_class <- output$argmax(dim = 2)$item()
    confidence <- probs[1, pred_class]$item()
  })

  # Return result
  list(
    class = class_names[pred_class],
    class_id = pred_class,
    confidence = confidence,
    all_probabilities = as.numeric(probs$cpu())
  )
}

# ============================================================================
# Usage Example
# ============================================================================

run_example <- function() {
  # Setup
  device <- if (cuda_is_available()) "cuda" else "cpu"

  # Example data: Sentiment classification
  train_texts <- c(
    "This movie was absolutely amazing, I loved it!",
    "Great acting and wonderful story, highly recommended.",
    "Terrible film, waste of time and money.",
    "Boring plot, poor acting, very disappointed.",
    "Fantastic cinematography and excellent direction!",
    "Awful movie, couldn't even finish watching.",
    "Brilliant performances, one of the best films I've seen.",
    "Very bad, would not recommend to anyone."
    # ... add more examples
  )

  train_labels <- c(
    2, 2,  # positive
    1, 1,  # negative
    2,     # positive
    1,     # negative
    2,     # positive
    1      # negative
  )

  val_texts <- c(
    "Beautiful movie with great actors.",
    "Complete disaster, terrible in every way."
  )

  val_labels <- c(2, 1)  # positive, negative

  # Train model
  result <- train_text_classifier(
    train_texts = train_texts,
    train_labels = train_labels,
    val_texts = val_texts,
    val_labels = val_labels,
    num_classes = 2,
    max_length = 50,
    embedding_dim = 128,
    hidden_dim = 256,
    num_epochs = 15,
    batch_size = 4,
    learning_rate = 0.001,
    device = device
  )

  # Predict on new text
  prediction <- predict_text_class(
    model_path = "best_text_model.pt",
    text = "This was an outstanding performance!",
    class_names = c("negative", "positive"),
    device = device
  )

  cat("\nPrediction for: 'This was an outstanding performance!'\n")
  cat("  Class:", prediction$class, "\n")
  cat("  Confidence:", sprintf("%.2f%%", prediction$confidence * 100), "\n")
}

# Run example (uncomment to execute)
# run_example()
```

## Key Patterns

### Text Preprocessing
- **Vocabulary building**: Map words to integer IDs
- **Padding**: Fixed-length sequences for batching
- **Tokenization**: Use `tokenizers` package
- **Unknown words**: Handle with `<UNK>` token

### LSTM Architecture
- **Embedding layer**: Convert token IDs to dense vectors
- **Bidirectional LSTM**: Captures context from both directions
- **Attention mechanism**: Weighted combination of all timesteps (vs just last)
- **Gradient clipping**: Essential for stable RNN training (max_norm = 5.0)

### Training Patterns
- **Packed sequences**: Efficiency with variable-length inputs (optional)
- **Gradient clipping**: Prevents exploding gradients in RNNs
- **Attention**: Better than last-hidden-state for long sequences

### Production Enhancements
- **Pre-trained embeddings**: Use GloVe, word2vec, FastText
- **Subword tokenization**: BPE, WordPiece for unknown words
- **Data augmentation**: Synonym replacement, back-translation
- **Ensemble**: Combine multiple models for better accuracy

## Advanced Variations

### GRU Instead of LSTM
```r
self$gru <- nn_gru(
  input_size = embedding_dim,
  hidden_size = hidden_dim,
  num_layers = num_layers,
  bidirectional = bidirectional,
  dropout = dropout,
  batch_first = TRUE
)
```

GRU is often faster and performs similarly to LSTM.

### Multi-Layer Attention
```r
# Self-attention over LSTM outputs
self$attention_layer <- nn_multi_head_attention(
  embed_dim = hidden_dim * self$num_directions,
  num_heads = 8,
  batch_first = TRUE
)
```

### Character-Level Embeddings
Combine word and character embeddings for better handling of rare/unknown words.

## Related

- Main skill: [torch-r SKILL.md](../SKILL.md)
- Custom training: [custom-training-loop-advanced.md](custom-training-loop-advanced.md)
- NLP patterns: Check `r-text-mining` skill for text preprocessing
