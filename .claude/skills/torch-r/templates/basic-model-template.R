# Basic torch Model Template
# Ready-to-use template for torch deep learning projects in R

library(torch)
library(coro)

# ============================================================================
# 1. CONFIGURATION
# ============================================================================

# Set device (GPU if available, otherwise CPU)
device <- if (cuda_is_available()) {
  cat("CUDA available! Using GPU\n")
  torch_device("cuda")
} else {
  cat("CUDA not available. Using CPU\n")
  torch_device("cpu")
}

# Hyperparameters
config <- list(
  # Data
  input_dim = 784,
  output_dim = 10,
  batch_size = 64,

  # Model
  hidden_dim = 256,
  dropout = 0.3,

  # Training
  num_epochs = 20,
  learning_rate = 0.001,

  # Paths
  model_path = "best_model.pt",
  log_path = "training_log.csv"
)

# ============================================================================
# 2. DATA PREPARATION
# ============================================================================

# TODO: Load your data here
# Example structure:
# train_x <- torch_tensor(your_training_data)  # Shape: [n_samples, features]
# train_y <- torch_tensor(your_training_labels, dtype = torch_long())  # Shape: [n_samples]
# val_x <- torch_tensor(your_validation_data)
# val_y <- torch_tensor(your_validation_labels, dtype = torch_long())

# Create dataset
simple_dataset <- dataset(
  name = "SimpleDataset",

  initialize = function(x, y) {
    self$x <- x
    self$y <- y
  },

  .getitem = function(i) {
    list(
      x = self$x[i, ],
      y = self$y[i]
    )
  },

  .length = function() {
    self$x$size(1)
  }
)

# Create dataloaders
train_ds <- simple_dataset(train_x, train_y)
val_ds <- simple_dataset(val_x, val_y)

train_dl <- dataloader(
  train_ds,
  batch_size = config$batch_size,
  shuffle = TRUE,
  num_workers = 0  # Set to 0 on Windows, >0 on Linux/Mac for parallel loading
)

val_dl <- dataloader(
  val_ds,
  batch_size = config$batch_size,
  shuffle = FALSE,
  num_workers = 0
)

# ============================================================================
# 3. MODEL DEFINITION
# ============================================================================

# Define your model as an nn_module
my_model <- nn_module(
  name = "MyModel",

  # Constructor - define layers
  initialize = function(input_dim, hidden_dim, output_dim, dropout = 0.3) {
    self$fc1 <- nn_linear(input_dim, hidden_dim)
    self$fc2 <- nn_linear(hidden_dim, hidden_dim)
    self$fc3 <- nn_linear(hidden_dim, output_dim)

    self$relu <- nn_relu()
    self$dropout <- nn_dropout(dropout)
    self$bn1 <- nn_batch_norm1d(hidden_dim)
    self$bn2 <- nn_batch_norm1d(hidden_dim)
  },

  # Forward pass - define computation
  forward = function(x) {
    x |>
      self$fc1() |>
      self$bn1() |>
      self$relu() |>
      self$dropout() |>
      self$fc2() |>
      self$bn2() |>
      self$relu() |>
      self$dropout() |>
      self$fc3()
  }
)

# Instantiate model
model <- my_model(
  input_dim = config$input_dim,
  hidden_dim = config$hidden_dim,
  output_dim = config$output_dim,
  dropout = config$dropout
)

# Move model to device
model$to(device = device)

# Print model summary
cat("\nModel Architecture:\n")
print(model)
cat("\nNumber of parameters:", length(model$parameters), "\n\n")

# ============================================================================
# 4. LOSS FUNCTION & OPTIMIZER
# ============================================================================

# Loss function
criterion <- nn_cross_entropy_loss()

# Optimizer
optimizer <- optim_adam(
  model$parameters,
  lr = config$learning_rate
)

# Learning rate scheduler (optional)
scheduler <- lr_step(
  optimizer,
  step_size = 10,  # Reduce LR every 10 epochs
  gamma = 0.5      # Multiply LR by 0.5
)

# ============================================================================
# 5. TRAINING LOOP
# ============================================================================

# Initialize tracking
training_history <- data.frame(
  epoch = integer(),
  train_loss = numeric(),
  train_acc = numeric(),
  val_loss = numeric(),
  val_acc = numeric()
)

best_val_acc <- 0

cat("Starting training...\n")
cat(str_pad("", width = 80, side = "both", pad = "="), "\n")

for (epoch in 1:config$num_epochs) {

  # ========== Training Phase ==========
  model$train()  # Set training mode

  train_loss <- 0
  train_correct <- 0
  train_total <- 0
  train_batches <- 0

  coro::loop(for (batch in train_dl) {
    # Move data to device
    x <- batch$x$to(device = device)
    y <- batch$y$to(device = device)

    # Forward pass
    optimizer$zero_grad()
    outputs <- model(x)
    loss <- criterion(outputs, y)

    # Backward pass
    loss$backward()

    # Optional: Gradient clipping (uncomment if needed)
    # nn_utils_clip_grad_norm_(model$parameters, max_norm = 1.0)

    # Update parameters
    optimizer$step()

    # Track metrics
    train_loss <- train_loss + loss$item()
    predictions <- outputs$argmax(dim = 2)
    train_correct <- train_correct + (predictions == y)$sum()$item()
    train_total <- train_total + y$size(1)
    train_batches <- train_batches + 1
  })

  # Compute training metrics
  avg_train_loss <- train_loss / train_batches
  train_accuracy <- train_correct / train_total

  # ========== Validation Phase ==========
  model$eval()  # Set evaluation mode

  val_loss <- 0
  val_correct <- 0
  val_total <- 0
  val_batches <- 0

  with_no_grad({  # Disable gradient computation
    coro::loop(for (batch in val_dl) {
      # Move data to device
      x <- batch$x$to(device = device)
      y <- batch$y$to(device = device)

      # Forward pass only
      outputs <- model(x)
      loss <- criterion(outputs, y)

      # Track metrics
      val_loss <- val_loss + loss$item()
      predictions <- outputs$argmax(dim = 2)
      val_correct <- val_correct + (predictions == y)$sum()$item()
      val_total <- val_total + y$size(1)
      val_batches <- val_batches + 1
    })
  })

  # Compute validation metrics
  avg_val_loss <- val_loss / val_batches
  val_accuracy <- val_correct / val_total

  # Update learning rate
  scheduler$step()

  # ========== Logging ==========

  # Print progress
  cat(sprintf(
    "Epoch %2d/%d | Train Loss: %.4f Acc: %.2f%% | Val Loss: %.4f Acc: %.2f%% | LR: %.6f\n",
    epoch,
    config$num_epochs,
    avg_train_loss,
    train_accuracy * 100,
    avg_val_loss,
    val_accuracy * 100,
    optimizer$param_groups[[1]]$lr
  ))

  # Save to history
  training_history <- rbind(
    training_history,
    data.frame(
      epoch = epoch,
      train_loss = avg_train_loss,
      train_acc = train_accuracy,
      val_loss = avg_val_loss,
      val_acc = val_accuracy
    )
  )

  # Save best model
  if (val_accuracy > best_val_acc) {
    best_val_acc <- val_accuracy
    torch_save(model, config$model_path)
    cat("  → Best model saved! (Val Acc: ", sprintf("%.2f%%", best_val_acc * 100), ")\n")
  }
}

cat(str_pad("", width = 80, side = "both", pad = "="), "\n")
cat("Training completed!\n")
cat("Best validation accuracy:", sprintf("%.2f%%", best_val_acc * 100), "\n\n")

# ============================================================================
# 6. SAVE TRAINING HISTORY
# ============================================================================

write.csv(training_history, config$log_path, row.names = FALSE)
cat("Training history saved to:", config$log_path, "\n")

# ============================================================================
# 7. VISUALIZATION (Optional)
# ============================================================================

# Uncomment to visualize training history
# library(ggplot2)
#
# # Loss curves
# ggplot(training_history, aes(x = epoch)) +
#   geom_line(aes(y = train_loss, color = "Train")) +
#   geom_line(aes(y = val_loss, color = "Validation")) +
#   labs(title = "Training & Validation Loss",
#        x = "Epoch", y = "Loss", color = "Dataset") +
#   theme_minimal()
#
# # Accuracy curves
# ggplot(training_history, aes(x = epoch)) +
#   geom_line(aes(y = train_acc, color = "Train")) +
#   geom_line(aes(y = val_acc, color = "Validation")) +
#   labs(title = "Training & Validation Accuracy",
#        x = "Epoch", y = "Accuracy", color = "Dataset") +
#   theme_minimal()

# ============================================================================
# 8. INFERENCE FUNCTION
# ============================================================================

#' Make predictions on new data
#'
#' @param model_path Path to saved model
#' @param new_data torch tensor or R matrix/array
#' @param device Device to use
#'
#' @return List with predictions and probabilities
predict_with_model <- function(model_path, new_data, device = "cpu") {
  # Load model
  model <- torch_load(model_path)
  model$to(device = device)
  model$eval()

  # Convert to tensor if needed
  if (!inherits(new_data, "torch_tensor")) {
    new_data <- torch_tensor(new_data)
  }
  new_data <- new_data$to(device = device)

  # Predict
  with_no_grad({
    outputs <- model(new_data)
    probabilities <- nnf_softmax(outputs, dim = 2)
    predictions <- outputs$argmax(dim = 2)
  })

  # Return results
  list(
    predictions = as.integer(predictions$cpu()),
    probabilities = as.matrix(probabilities$cpu())
  )
}

# Example usage:
# results <- predict_with_model(config$model_path, new_data_tensor, device = device)
# cat("Predictions:", results$predictions, "\n")

# ============================================================================
# DONE!
# ============================================================================
