# Audio Classification with torch - Complete Example

This example demonstrates how to build an audio classification system using torch for R, covering:
- Audio preprocessing (mel-spectrograms)
- Custom dataset for audio files
- CNN architecture for spectrogram classification
- Complete training pipeline
- Inference and evaluation

## Problem

Classify audio samples into categories (e.g., bird species, urban sounds, music genres).

## Solution Overview

1. Convert audio waveforms to mel-spectrograms
2. Treat spectrograms as 2D images (time × frequency)
3. Use CNN architecture
4. Train with custom dataloader

## Complete Implementation

```r
library(torch)
library(tuneR)
library(seewave)
library(coro)

# ============================================================================
# Part 1: Audio Preprocessing
# ============================================================================

#' Convert audio file to mel-spectrogram tensor
#'
#' @param audio_path Path to audio file
#' @param sample_rate Target sample rate (Hz)
#' @param n_mels Number of mel bands
#' @param n_fft FFT window size
#' @param hop_length Hop length for STFT
#' @param duration Fixed duration (seconds), will pad/crop
#'
#' @return torch tensor of shape [1, n_mels, time_steps]
audio_to_melspec <- function(audio_path, sample_rate = 16000, n_mels = 64,
                              n_fft = 1024, hop_length = 512, duration = 3) {
  # Load audio
  wave <- readWave(audio_path)

  # Resample if needed
  if (wave@samp.rate != sample_rate) {
    wave <- resamp(wave, f = wave@samp.rate, g = sample_rate)
  }

  # Convert to mono if stereo
  if (wave@stereo) {
    audio <- (wave@left + wave@right) / 2
  } else {
    audio <- wave@left
  }

  # Normalize to [-1, 1]
  audio <- audio / max(abs(audio))

  # Pad or crop to fixed duration
  target_length <- duration * sample_rate
  current_length <- length(audio)

  if (current_length < target_length) {
    # Pad with zeros
    padding <- rep(0, target_length - current_length)
    audio <- c(audio, padding)
  } else if (current_length > target_length) {
    # Crop from center
    start_idx <- (current_length - target_length) %/% 2
    audio <- audio[start_idx:(start_idx + target_length - 1)]
  }

  # Compute STFT
  spec <- spectro(
    audio,
    f = sample_rate,
    wl = n_fft,
    ovlp = (1 - hop_length / n_fft) * 100,
    plot = FALSE
  )

  # Get magnitude spectrogram
  magnitude <- abs(spec$amp)

  # Convert to mel scale (simplified - use proper mel filter banks in production)
  # For production, use torchaudio equivalent or custom mel filter implementation
  mel_spec <- magnitude  # Placeholder - implement mel filtering

  # Convert to dB scale
  mel_spec_db <- 20 * log10(mel_spec + 1e-10)

  # Normalize
  mel_spec_db <- (mel_spec_db - mean(mel_spec_db)) / sd(mel_spec_db)

  # Convert to torch tensor [1, n_mels, time]
  tensor <- torch_tensor(mel_spec_db)$unsqueeze(1)

  return(tensor)
}

# ============================================================================
# Part 2: Custom Dataset
# ============================================================================

#' Audio Classification Dataset
#'
#' @param audio_files Character vector of audio file paths
#' @param labels Integer vector of class labels (1-indexed)
#' @param ... Additional arguments passed to audio_to_melspec
audio_dataset <- dataset(
  name = "AudioDataset",

  initialize = function(audio_files, labels, ...) {
    self$audio_files <- audio_files
    self$labels <- torch_tensor(labels, dtype = torch_long())
    self$preprocessing_args <- list(...)
  },

  .getitem = function(i) {
    # Load and preprocess audio
    spec <- do.call(
      audio_to_melspec,
      c(list(audio_path = self$audio_files[i]), self$preprocessing_args)
    )

    # Return list with spectrogram and label
    list(
      spectrogram = spec$squeeze(1),  # Remove batch dim [n_mels, time]
      label = self$labels[i]
    )
  },

  .length = function() {
    length(self$audio_files)
  }
)

# ============================================================================
# Part 3: CNN Architecture for Spectrograms
# ============================================================================

#' CNN for Audio Spectrogram Classification
#'
#' Architecture: Conv blocks with pooling -> Global pooling -> Dense
spectrogram_cnn <- nn_module(
  name = "SpectrogramCNN",

  initialize = function(num_classes, input_channels = 1) {
    # Convolutional blocks
    self$conv1 <- nn_conv2d(input_channels, 32, kernel_size = 3, padding = 1)
    self$bn1 <- nn_batch_norm2d(32)

    self$conv2 <- nn_conv2d(32, 64, kernel_size = 3, padding = 1)
    self$bn2 <- nn_batch_norm2d(64)

    self$conv3 <- nn_conv2d(64, 128, kernel_size = 3, padding = 1)
    self$bn3 <- nn_batch_norm2d(128)

    self$conv4 <- nn_conv2d(128, 256, kernel_size = 3, padding = 1)
    self$bn4 <- nn_batch_norm2d(256)

    # Pooling and regularization
    self$pool <- nn_max_pool2d(kernel_size = 2, stride = 2)
    self$dropout <- nn_dropout(0.3)
    self$global_pool <- nn_adaptive_avg_pool2d(c(1, 1))

    # Classification head
    self$fc1 <- nn_linear(256, 128)
    self$fc2 <- nn_linear(128, num_classes)

    self$relu <- nn_relu()
  },

  forward = function(x) {
    # x shape: [batch, 1, n_mels, time] or [batch, n_mels, time]

    # Ensure 4D input
    if (length(x$shape) == 3) {
      x <- x$unsqueeze(2)  # Add channel dimension
    }

    # Conv block 1
    x <- x |>
      self$conv1() |>
      self$bn1() |>
      self$relu() |>
      self$pool()

    # Conv block 2
    x <- x |>
      self$conv2() |>
      self$bn2() |>
      self$relu() |>
      self$pool()

    # Conv block 3
    x <- x |>
      self$conv3() |>
      self$bn3() |>
      self$relu() |>
      self$pool()

    # Conv block 4
    x <- x |>
      self$conv4() |>
      self$bn4() |>
      self$relu() |>
      self$dropout()

    # Global average pooling
    x <- self$global_pool(x)  # [batch, 256, 1, 1]
    x <- x$view(c(x$size(1), -1))  # [batch, 256]

    # Classification
    x <- x |>
      self$fc1() |>
      self$relu() |>
      self$dropout() |>
      self$fc2()

    return(x)
  }
)

# ============================================================================
# Part 4: Training Pipeline
# ============================================================================

#' Train audio classification model
#'
#' @param train_files Character vector of training audio files
#' @param train_labels Integer vector of training labels
#' @param val_files Character vector of validation audio files
#' @param val_labels Integer vector of validation labels
#' @param num_classes Number of output classes
#' @param num_epochs Number of training epochs
#' @param batch_size Batch size
#' @param learning_rate Learning rate
#' @param device Device ("cuda" or "cpu")
train_audio_classifier <- function(train_files, train_labels,
                                   val_files, val_labels,
                                   num_classes,
                                   num_epochs = 50,
                                   batch_size = 16,
                                   learning_rate = 0.001,
                                   device = "cpu") {

  # Create datasets
  train_ds <- audio_dataset(
    train_files,
    train_labels,
    sample_rate = 16000,
    n_mels = 64,
    duration = 3
  )

  val_ds <- audio_dataset(
    val_files,
    val_labels,
    sample_rate = 16000,
    n_mels = 64,
    duration = 3
  )

  # Create dataloaders
  train_dl <- dataloader(
    train_ds,
    batch_size = batch_size,
    shuffle = TRUE,
    num_workers = 0
  )

  val_dl <- dataloader(
    val_ds,
    batch_size = batch_size,
    shuffle = FALSE,
    num_workers = 0
  )

  # Initialize model
  model <- spectrogram_cnn(num_classes = num_classes)
  model$to(device = device)

  # Loss and optimizer
  criterion <- nn_cross_entropy_loss()
  optimizer <- optim_adam(model$parameters, lr = learning_rate)

  # Learning rate scheduler
  scheduler <- lr_step(optimizer, step_size = 15, gamma = 0.5)

  # Training loop
  best_val_acc <- 0

  for (epoch in 1:num_epochs) {
    # ========== Training ==========
    model$train()
    train_loss <- 0
    train_correct <- 0
    train_total <- 0

    coro::loop(for (batch in train_dl) {
      # Move to device
      specs <- batch$spectrogram$to(device = device)
      labels <- batch$label$to(device = device)

      # Forward pass
      optimizer$zero_grad()
      outputs <- model(specs)
      loss <- criterion(outputs, labels)

      # Backward pass
      loss$backward()
      nn_utils_clip_grad_norm_(model$parameters, max_norm = 1.0)
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
        specs <- batch$spectrogram$to(device = device)
        labels <- batch$label$to(device = device)

        outputs <- model(specs)
        loss <- criterion(outputs, labels)

        val_loss <- val_loss + loss$item()
        predictions <- outputs$argmax(dim = 2)
        val_correct <- val_correct + (predictions == labels)$sum()$item()
        val_total <- val_total + labels$size(1)
      })
    })

    val_accuracy <- val_correct / val_total
    avg_val_loss <- val_loss / length(val_dl)

    # Learning rate scheduling
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
      torch_save(model, "best_audio_model.pt")
      cat("  → Best model saved!\n")
    }
  }

  return(model)
}

# ============================================================================
# Part 5: Inference
# ============================================================================

#' Predict class for new audio file
#'
#' @param model_path Path to saved model
#' @param audio_path Path to audio file
#' @param class_names Character vector of class names
#' @param device Device ("cuda" or "cpu")
predict_audio_class <- function(model_path, audio_path, class_names, device = "cpu") {
  # Load model
  model <- torch_load(model_path)
  model$to(device = device)
  model$eval()

  # Preprocess audio
  spec <- audio_to_melspec(
    audio_path,
    sample_rate = 16000,
    n_mels = 64,
    duration = 3
  )
  spec <- spec$to(device = device)

  # Predict
  with_no_grad({
    output <- model(spec)
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

# Example usage (with dummy data structure)
run_example <- function() {
  # Setup
  device <- if (cuda_is_available()) "cuda" else "cpu"

  # Prepare data (replace with your actual file paths and labels)
  train_files <- c(
    "audio/train/bird1.wav",
    "audio/train/bird2.wav",
    "audio/train/cat1.wav",
    "audio/train/cat2.wav"
    # ... more files
  )

  train_labels <- c(1, 1, 2, 2)  # 1 = bird, 2 = cat

  val_files <- c(
    "audio/val/bird_val.wav",
    "audio/val/cat_val.wav"
  )

  val_labels <- c(1, 2)

  # Train model
  model <- train_audio_classifier(
    train_files = train_files,
    train_labels = train_labels,
    val_files = val_files,
    val_labels = val_labels,
    num_classes = 2,
    num_epochs = 30,
    batch_size = 16,
    learning_rate = 0.001,
    device = device
  )

  # Inference on new audio
  result <- predict_audio_class(
    model_path = "best_audio_model.pt",
    audio_path = "audio/test/unknown.wav",
    class_names = c("bird", "cat"),
    device = device
  )

  cat("\nPrediction:\n")
  cat("  Class:", result$class, "\n")
  cat("  Confidence:", sprintf("%.2f%%", result$confidence * 100), "\n")
}

# Run example (uncomment to execute)
# run_example()
```

## Key Patterns

### Audio Preprocessing
- **Fixed duration**: Pad or crop all audio to same length for batching
- **Mel-spectrogram**: Converts audio to 2D time-frequency representation
- **Normalization**: Essential for stable training
- **Data augmentation**: Consider time stretching, pitch shifting, adding noise

### CNN Architecture
- **2D convolutions**: Treat spectrogram as image (frequency × time)
- **Batch normalization**: Stabilizes training
- **Global pooling**: Handles variable-sized feature maps
- **Dropout**: Prevents overfitting on limited audio data

### Training
- **Gradient clipping**: Prevents exploding gradients
- **Learning rate scheduling**: Improves convergence
- **Early stopping**: Save best validation model

### Production Considerations
- Use proper mel filter banks (not simplified version shown)
- Implement data augmentation (SpecAugment)
- Handle variable-length audio efficiently
- Add confidence thresholding for unknown class detection

## Related

- Main skill: [torch-r SKILL.md](../SKILL.md)
- Custom training loops: [custom-training-loop-advanced.md](custom-training-loop-advanced.md)
- Bioacoustics patterns: Check `r-bioacoustics` skill for domain-specific preprocessing
