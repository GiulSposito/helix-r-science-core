---
name: torch-r
description: Master torch (PyTorch for R) deep learning with maximum flexibility and control. Use when mentions "torch", "torch em R", "torch for R", "torch in R", "PyTorch R", "pt", "nn_module", "nn_linear", "nn_conv", "nn_sequential", "torch_tensor", "autograd", "automatic differentiation", "custom training loop", "manual training", "backpropagation", "gradient manipulation", "research model", "custom loss function", "custom layer", "torch dataset", "dataloader", "GPU torch", "CUDA torch", "treinar com torch", "rede neural torch", "CNN torch", "RNN torch", "LSTM torch", "GRU torch", "attention mechanism", "transformer torch", "audio torch", "NLP torch", "vision torch", "time series torch", "torch flexibility", "torch control", "low-level training", "research deep learning", "experimental models", "dynamic computation graph", "when use torch", "torch vs keras", "torch or keras3", "torch benefits", "LibTorch", "mlverse torch", "torch for research", "torch for production", or working with torch R package for deep learning, neural networks, and scientific computing with explicit control.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# torch (PyTorch for R) - Maximum Flexibility Deep Learning

Expert guidance for deep learning in R using **torch**, the R interface to LibTorch (PyTorch C++ backend), providing maximum flexibility and explicit control over neural network design, training, and experimentation.

## Overview

### What is torch?

**torch** is an R package that provides a native R interface to **LibTorch**, the C++ backend of PyTorch. It offers:

- **Tensors**: Multidimensional arrays with GPU acceleration
- **Autograd**: Automatic differentiation for gradient-based optimization
- **Neural network modules**: Building blocks for custom architectures (`nn_module`, `nn_*` layers)
- **Optimizers**: SGD, Adam, RMSprop, and more
- **Full control**: Custom training loops, loss functions, layers, and gradient manipulation

torch is currently **the most modern and flexible framework in the R ecosystem for deep learning**, especially suited for:
- Research and experimentation
- Custom architectures and training procedures
- Low-level control over gradient computation
- Models requiring dynamic computation graphs
- Integration with PyTorch ecosystem (transfer learning, pretrained models)

### Key Documentation Resources

- **Official site**: https://torch.mlverse.org
- **CRAN manual**: https://mlverse.r-universe.dev/torch/doc/manual.html
- **Official book**: "Deep Learning and Scientific Computing with R torch" (https://torch.mlverse.org/resources/)
- **Practical materials**: https://mlverse.github.io/torchbook_materials/

## When to Use torch

### Use torch when you need:

✅ **Maximum flexibility and control**
- Custom training loops with explicit forward/backward passes
- Non-standard loss functions or gradient manipulation
- Dynamic network architectures that change during training
- Research experiments requiring low-level access

✅ **PyTorch ecosystem integration**
- Transfer learning from PyTorch pretrained models
- Reproducing PyTorch research papers in R
- Sharing models between Python PyTorch and R torch

✅ **Explicit gradient control**
- Custom gradient clipping or modification
- Multi-task learning with weighted gradients
- Debugging gradient flow in complex architectures

✅ **Scientific computing beyond ML**
- Differentiable simulations
- Physics-informed neural networks
- Optimization problems with custom constraints

### Use keras3 instead when:

⚠️ **High-level API preferred**
- Rapid prototyping with minimal code
- Standard architectures (ResNet, EfficientNet, etc.)
- Built-in `fit()` workflow with callbacks
- Preprocessing layers in model graph

### Use r-tensorflow instead when:

⚠️ **Deployment and infrastructure focus**
- TensorFlow Serving deployment
- SavedModel format required
- Integration with existing TensorFlow pipelines

**Decision matrix**: See [references/torch-vs-keras-comparison.md](references/torch-vs-keras-comparison.md)

## Core Concepts

### 1. Tensors - Fundamental Data Structure

Tensors are multidimensional arrays, the building blocks of all torch operations.

```r
library(torch)

# Create tensors from R vectors/matrices
x <- torch_tensor(c(1, 2, 3, 4, 5, 6))
print(x)
# torch_tensor
#  1  2  3  4  5  6
# [ CPUFloatType{6} ]

# Reshape tensors
x <- x$view(c(2, 3))  # 2x3 matrix
print(x)
# torch_tensor
#  1  2  3
#  4  5  6
# [ CPUFloatType{2,3} ]

# Create tensors with specific properties
zeros <- torch_zeros(c(3, 4))         # 3x4 matrix of zeros
ones <- torch_ones(c(2, 2))           # 2x2 matrix of ones
random <- torch_randn(c(5, 5))        # 5x5 random normal
arange <- torch_arange(0, 10, 0.5)    # sequence from 0 to 10 by 0.5

# Tensor operations are chainable using $ (R6 object method access)
result <- torch_randn(c(3, 3))$
  abs()$
  sqrt()$
  mean()

print(result)  # scalar tensor with mean value
```

**Key R-specific patterns:**
- Access tensor methods with `$` (e.g., `tensor$view()`, `tensor$mean()`)
- torch uses **R6 objects**, not S3/S4
- Indexing is **1-based** in R, unlike Python (0-based)

### 2. Device Management (CPU/GPU)

torch supports GPU acceleration via CUDA.

```r
# Check CUDA availability
if (cuda_is_available()) {
  cat("CUDA is available!\n")
  cat("Device count:", cuda_device_count(), "\n")
} else {
  cat("CUDA not available, using CPU\n")
}

# Set device
device <- if (cuda_is_available()) torch_device("cuda") else torch_device("cpu")

# Move tensors to device
x <- torch_randn(c(100, 100))
x_gpu <- x$to(device = device)

# Operations on GPU tensors stay on GPU
y_gpu <- x_gpu$matmul(x_gpu$t())  # matrix multiplication on GPU

# Move back to CPU for R operations
y_cpu <- y_gpu$cpu()
y_r <- as_array(y_cpu)  # convert to R array
```

**Best practice**: Set device once and reuse throughout training:
```r
device <- if (cuda_is_available()) "cuda" else "cpu"
```

### 3. Autograd - Automatic Differentiation

torch automatically tracks operations for gradient computation.

```r
# Enable gradient tracking with requires_grad = TRUE
x <- torch_tensor(2.0, requires_grad = TRUE)
y <- x^2 + 3*x + 1

# Compute gradients
y$backward()

# Access gradient
print(x$grad)  # dy/dx = 2*x + 3 = 2*2 + 3 = 7
# torch_tensor
#  7
# [ CPUFloatType{1} ]

# Gradient accumulation example
x <- torch_tensor(1.0, requires_grad = TRUE)

# First computation
y1 <- x^2
y1$backward()
print(x$grad)  # 2*1 = 2

# Gradients accumulate! Must zero them manually
y2 <- x^3
y2$backward()
print(x$grad)  # 2 + 3*1 = 5 (accumulated!)

# Zero gradients manually
x$grad$zero_()
y3 <- x^2
y3$backward()
print(x$grad)  # 2 (reset first)
```

**Critical pattern**: Always zero gradients in training loops!
```r
optimizer$zero_grad()  # zero all parameter gradients
loss$backward()        # compute gradients
optimizer$step()       # update parameters
```

### 4. nn_module - Neural Network Building Blocks

`nn_module` is the base class for all neural networks in torch.

```r
library(torch)

# Define custom module using nn_module()
simple_net <- nn_module(
  "SimpleNet",

  # Constructor - define layers
  initialize = function(input_size, hidden_size, output_size) {
    self$fc1 <- nn_linear(input_size, hidden_size)
    self$fc2 <- nn_linear(hidden_size, output_size)
    self$relu <- nn_relu()
  },

  # Forward pass - define computation
  forward = function(x) {
    x |>
      self$fc1() |>
      self$relu() |>
      self$fc2()
  }
)

# Instantiate the model
model <- simple_net(input_size = 10, hidden_size = 64, output_size = 3)

# Forward pass
input <- torch_randn(c(32, 10))  # batch of 32 samples
output <- model(input)           # forward pass
print(output$shape)              # [32, 3]

# Access parameters
print(length(model$parameters))  # 4 (2 weights + 2 biases)

# Move to device
model$to(device = device)
```

**nn_module patterns:**
- `initialize()` = constructor (like `__init__` in PyTorch)
- `forward()` = forward pass (like `forward()` in PyTorch)
- Access layers with `self$layer_name`
- Use `|>` (pipe) for sequential operations

### 5. nn_sequential - Quick Layer Stacking

For simple sequential models, use `nn_sequential()`:

```r
# Sequential model (no custom forward needed)
model <- nn_sequential(
  nn_linear(784, 128),
  nn_relu(),
  nn_dropout(0.2),
  nn_linear(128, 64),
  nn_relu(),
  nn_linear(64, 10)
)

# Use like any nn_module
output <- model(torch_randn(c(16, 784)))
print(output$shape)  # [16, 10]
```

**When to use:**
- ✅ Simple feedforward architectures
- ✅ No custom logic in forward pass
- ❌ Skip connections, branching, or conditional logic → use `nn_module`

### 6. Loss Functions

torch provides standard loss functions as `nn_*` modules:

```r
# Classification losses
ce_loss <- nn_cross_entropy_loss()
bce_loss <- nn_bce_loss()                    # binary cross-entropy
bce_logits <- nn_bce_with_logits_loss()     # more stable version

# Regression losses
mse_loss <- nn_mse_loss()
mae_loss <- nn_l1_loss()
smooth_l1 <- nn_smooth_l1_loss()

# Usage example
predictions <- torch_randn(c(32, 10))  # raw logits (no softmax!)
targets <- torch_randint(1, 10, c(32)) # class indices (1-based in R!)

loss <- ce_loss(predictions, targets)
print(loss)
```

**Important**: `nn_cross_entropy_loss()` expects:
- Predictions: raw logits (no softmax)
- Targets: class indices (1-based in R, unlike Python!)

### 7. Optimizers

Optimizers update model parameters based on computed gradients.

```r
# Common optimizers
optimizer <- optim_adam(model$parameters, lr = 0.001)
optimizer <- optim_sgd(model$parameters, lr = 0.01, momentum = 0.9)
optimizer <- optim_rmsprop(model$parameters, lr = 0.001)

# Training step pattern
optimizer$zero_grad()    # zero gradients
output <- model(input)   # forward pass
loss <- loss_fn(output, target)
loss$backward()          # backward pass
optimizer$step()         # update parameters

# Learning rate scheduling
scheduler <- lr_step(optimizer, step_size = 10, gamma = 0.1)
# After each epoch:
scheduler$step()
```

### 8. Datasets and DataLoaders

torch provides `dataset` and `dataloader` for efficient data handling.

```r
# Define custom dataset
my_dataset <- dataset(
  "MyDataset",

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
    nrow(self$x)
  }
)

# Instantiate dataset
x_data <- torch_randn(c(1000, 10))
y_data <- torch_randint(1, 3, c(1000))
ds <- my_dataset(x_data, y_data)

# Create dataloader for batching
dl <- dataloader(
  ds,
  batch_size = 32,
  shuffle = TRUE,
  num_workers = 0  # parallel loading (set to 0 on Windows)
)

# Iterate over batches
coro::loop(for (batch in dl) {
  # batch is a list with x and y
  x <- batch$x
  y <- batch$y

  # Training step
  optimizer$zero_grad()
  output <- model(x)
  loss <- loss_fn(output, y)
  loss$backward()
  optimizer$step()
})
```

**Key pattern**: Use `coro::loop()` for dataloader iteration in R.

## Training Patterns

### Basic Training Loop

```r
library(torch)
library(coro)

# Setup
model <- simple_net(10, 64, 3)
model$to(device = device)
optimizer <- optim_adam(model$parameters, lr = 0.001)
loss_fn <- nn_cross_entropy_loss()

# Training loop
num_epochs <- 10

for (epoch in 1:num_epochs) {
  model$train()  # set to training mode

  train_loss <- 0
  batch_count <- 0

  coro::loop(for (batch in train_dl) {
    # Move to device
    x <- batch$x$to(device = device)
    y <- batch$y$to(device = device)

    # Forward pass
    optimizer$zero_grad()
    output <- model(x)
    loss <- loss_fn(output, y)

    # Backward pass
    loss$backward()
    optimizer$step()

    # Track loss
    train_loss <- train_loss + loss$item()
    batch_count <- batch_count + 1
  })

  # Print epoch statistics
  avg_loss <- train_loss / batch_count
  cat(sprintf("Epoch %d: Loss = %.4f\n", epoch, avg_loss))
}
```

### Evaluation Loop

```r
# Evaluation (no gradient tracking)
model$eval()  # set to evaluation mode

test_loss <- 0
correct <- 0
total <- 0

with_no_grad({  # disable gradient tracking
  coro::loop(for (batch in test_dl) {
    x <- batch$x$to(device = device)
    y <- batch$y$to(device = device)

    # Forward pass only
    output <- model(x)
    loss <- loss_fn(output, y)

    # Compute accuracy
    predictions <- output$argmax(dim = 2)  # get predicted class
    correct <- correct + (predictions == y)$sum()$item()
    total <- total + y$size(1)

    test_loss <- test_loss + loss$item()
  })
})

accuracy <- correct / total
cat(sprintf("Test Accuracy: %.2f%%\n", accuracy * 100))
```

**Critical patterns:**
- `model$train()` before training (enables dropout, batch norm training mode)
- `model$eval()` before evaluation (disables dropout, batch norm eval mode)
- `with_no_grad({...})` during evaluation (disables autograd for efficiency)

## Domain-Specific Applications

### Computer Vision - CNN Architecture

```r
library(torch)

# Convolutional Neural Network
cnn_model <- nn_module(
  "CNNClassifier",

  initialize = function(num_classes = 10) {
    # Convolutional layers
    self$conv1 <- nn_conv2d(3, 32, kernel_size = 3, padding = 1)
    self$conv2 <- nn_conv2d(32, 64, kernel_size = 3, padding = 1)
    self$conv3 <- nn_conv2d(64, 128, kernel_size = 3, padding = 1)

    self$pool <- nn_max_pool2d(kernel_size = 2, stride = 2)
    self$relu <- nn_relu()
    self$dropout <- nn_dropout(0.25)

    # Fully connected layers
    self$fc1 <- nn_linear(128 * 4 * 4, 512)
    self$fc2 <- nn_linear(512, num_classes)
  },

  forward = function(x) {
    # Convolutional blocks
    x <- x |>
      self$conv1() |> self$relu() |> self$pool() |>
      self$conv2() |> self$relu() |> self$pool() |>
      self$conv3() |> self$relu() |> self$pool()

    # Flatten
    x <- x$view(c(x$size(1), -1))

    # Dense layers
    x <- x |>
      self$fc1() |> self$relu() |> self$dropout() |>
      self$fc2()

    return(x)
  }
)

# Usage with image data
# Input shape: [batch, channels, height, width]
model <- cnn_model(num_classes = 10)
input <- torch_randn(c(16, 3, 32, 32))  # 16 images, 3 channels, 32x32
output <- model(input)
print(output$shape)  # [16, 10]
```

**CNN patterns:**
- Input format: `[batch, channels, height, width]`
- Use `nn_conv2d()` for 2D convolutions
- `nn_max_pool2d()` or `nn_avg_pool2d()` for downsampling
- `view()` to flatten before fully connected layers

### NLP - LSTM for Text Classification

```r
library(torch)

# LSTM text classifier
lstm_model <- nn_module(
  "LSTMClassifier",

  initialize = function(vocab_size, embedding_dim, hidden_dim, output_dim,
                        n_layers = 1, bidirectional = FALSE, dropout = 0.5) {
    self$embedding <- nn_embedding(vocab_size, embedding_dim)
    self$lstm <- nn_lstm(
      embedding_dim,
      hidden_dim,
      num_layers = n_layers,
      bidirectional = bidirectional,
      dropout = if (n_layers > 1) dropout else 0,
      batch_first = TRUE
    )

    self$fc <- nn_linear(
      hidden_dim * (if (bidirectional) 2 else 1),
      output_dim
    )
    self$dropout <- nn_dropout(dropout)
  },

  forward = function(text) {
    # text shape: [batch, seq_len]

    # Embedding
    embedded <- self$embedding(text)  # [batch, seq_len, embedding_dim]
    embedded <- self$dropout(embedded)

    # LSTM
    lstm_out <- self$lstm(embedded)
    output <- lstm_out[[1]]  # [batch, seq_len, hidden_dim * directions]

    # Use final hidden state for classification
    # Take last timestep output
    final_output <- output[, -1, ]  # [batch, hidden_dim * directions]

    # Classification layer
    logits <- self$fc(self$dropout(final_output))

    return(logits)
  }
)

# Usage
model <- lstm_model(
  vocab_size = 10000,
  embedding_dim = 128,
  hidden_dim = 256,
  output_dim = 5,  # 5 classes
  n_layers = 2,
  bidirectional = TRUE,
  dropout = 0.5
)

# Input: token indices [batch, sequence_length]
input <- torch_randint(1, 10000, c(32, 50))  # 32 sequences of length 50
output <- model(input)
print(output$shape)  # [32, 5]
```

**LSTM patterns:**
- `nn_embedding()` for token → vector conversion
- `nn_lstm()` returns list: `[[1]]` = outputs, `[[2]]` = hidden state
- Set `batch_first = TRUE` for `[batch, seq, features]` format
- Bidirectional LSTM doubles hidden dimension

### Time Series - Forecasting with RNN

```r
library(torch)

# RNN for time series forecasting
rnn_forecaster <- nn_module(
  "RNNForecaster",

  initialize = function(input_size, hidden_size, num_layers, output_size, dropout = 0.2) {
    self$rnn <- nn_gru(
      input_size,
      hidden_size,
      num_layers = num_layers,
      dropout = dropout,
      batch_first = TRUE
    )
    self$fc <- nn_linear(hidden_size, output_size)
  },

  forward = function(x) {
    # x shape: [batch, seq_len, features]

    rnn_out <- self$rnn(x)
    output <- rnn_out[[1]]  # [batch, seq_len, hidden_size]

    # Use last timestep for prediction
    last_output <- output[, -1, ]  # [batch, hidden_size]

    # Forecast
    forecast <- self$fc(last_output)  # [batch, output_size]

    return(forecast)
  }
)

# Usage: predict next 10 timesteps from last 50
model <- rnn_forecaster(
  input_size = 5,      # 5 features
  hidden_size = 128,
  num_layers = 2,
  output_size = 10     # predict next 10 steps
)

# Input: [batch, lookback_window, features]
input <- torch_randn(c(16, 50, 5))  # 16 series, 50 timesteps, 5 features
output <- model(input)
print(output$shape)  # [16, 10]
```

**Time series patterns:**
- Use `nn_gru()` or `nn_lstm()` for sequential data
- Input format: `[batch, sequence_length, features]`
- Output last timestep for many-to-one forecasting
- Output all timesteps for sequence-to-sequence

### Audio - Spectrogram CNN

See complete example: [examples/audio-classification-torch.md](examples/audio-classification-torch.md)

**Key patterns:**
- Convert waveform to mel-spectrogram
- Treat spectrogram as 2D image (time × frequency)
- Use CNN architecture (similar to computer vision)
- Handle variable-length audio with padding or cropping

## Advanced Topics

### Custom Loss Functions

```r
# Custom loss as nn_module
focal_loss <- nn_module(
  "FocalLoss",

  initialize = function(alpha = 1, gamma = 2) {
    self$alpha <- alpha
    self$gamma <- gamma
    self$ce_loss <- nn_cross_entropy_loss(reduction = "none")
  },

  forward = function(inputs, targets) {
    # Standard cross-entropy
    ce <- self$ce_loss(inputs, targets)

    # Get probabilities
    probs <- nnf_softmax(inputs, dim = 2)
    targets_one_hot <- nnf_one_hot(targets, num_classes = inputs$size(2))
    pt <- (probs * targets_one_hot)$sum(dim = 2)

    # Focal loss formula
    focal_weight <- (1 - pt)^self$gamma
    loss <- self$alpha * focal_weight * ce

    return(loss$mean())
  }
)

# Usage
loss_fn <- focal_loss(alpha = 1, gamma = 2)
loss <- loss_fn(predictions, targets)
```

### Custom Layers

```r
# Custom layer with learnable parameters
attention_layer <- nn_module(
  "AttentionLayer",

  initialize = function(hidden_dim) {
    self$attention_weights <- nn_linear(hidden_dim, 1)
  },

  forward = function(x) {
    # x shape: [batch, seq_len, hidden_dim]

    # Compute attention scores
    scores <- self$attention_weights(x)  # [batch, seq_len, 1]
    scores <- scores$squeeze(3)          # [batch, seq_len]

    # Softmax attention weights
    weights <- nnf_softmax(scores, dim = 2)  # [batch, seq_len]

    # Weighted sum
    weights_expanded <- weights$unsqueeze(3)  # [batch, seq_len, 1]
    weighted <- x * weights_expanded          # [batch, seq_len, hidden_dim]
    output <- weighted$sum(dim = 2)           # [batch, hidden_dim]

    return(output)
  }
)
```

### Custom Training Loop with Gradient Manipulation

```r
# Advanced training with gradient clipping and mixed precision
train_advanced <- function(model, train_dl, num_epochs = 10) {
  optimizer <- optim_adam(model$parameters, lr = 0.001)
  loss_fn <- nn_cross_entropy_loss()

  for (epoch in 1:num_epochs) {
    model$train()

    coro::loop(for (batch in train_dl) {
      x <- batch$x$to(device = device)
      y <- batch$y$to(device = device)

      # Forward pass
      optimizer$zero_grad()
      output <- model(x)
      loss <- loss_fn(output, y)

      # Backward pass
      loss$backward()

      # Gradient clipping (prevent exploding gradients)
      nn_utils_clip_grad_norm_(model$parameters, max_norm = 1.0)

      # Update
      optimizer$step()
    })

    cat(sprintf("Epoch %d completed\n", epoch))
  }
}
```

### Multi-GPU Training

```r
library(torch)

# Check multiple GPUs
if (cuda_device_count() > 1) {
  cat(sprintf("Using %d GPUs\n", cuda_device_count()))

  # Wrap model for data parallelism
  model <- nn_data_parallel(model)
}

# Training works the same way
model$to(device = "cuda")

# DataLoader handles batching across GPUs automatically
dl <- dataloader(dataset, batch_size = 32 * cuda_device_count(), shuffle = TRUE)
```

### Transfer Learning

```r
# Load pretrained model (if available)
# Note: torch for R has limited pretrained models compared to torchvision
# Consider using reticulate to load PyTorch models

# Example: Fine-tuning approach
pretrained_model <- my_pretrained_net()

# Freeze early layers
for (param in pretrained_model$conv1$parameters) {
  param$requires_grad_(FALSE)
}
for (param in pretrained_model$conv2$parameters) {
  param$requires_grad_(FALSE)
}

# Replace final layer
pretrained_model$fc <- nn_linear(512, num_classes)

# Only train unfrozen parameters
trainable_params <- purrr::keep(
  pretrained_model$parameters,
  ~.x$requires_grad
)
optimizer <- optim_adam(trainable_params, lr = 0.001)
```

**Transfer learning patterns:**
- Freeze layers with `param$requires_grad_(FALSE)`
- Replace final layer for new task
- Only pass trainable parameters to optimizer
- Use lower learning rate for fine-tuning

## Integration with Other Skills

### r-deeplearning Skill

**When to use r-deeplearning:**
- Framework comparison guidance (torch vs keras3 vs tensorflow)
- Decision matrix for selecting framework
- General deep learning concepts independent of framework
- Multi-framework projects

**Pattern**: Use r-deeplearning for strategic decisions, then torch-r for implementation.

### keras3 Skill

**When to use keras3:**
- Rapid prototyping with minimal code
- Standard architectures (ResNet, EfficientNet, etc.)
- Built-in `fit()` workflow with callbacks sufficient
- Preprocessing layers in model graph
- Multi-backend flexibility (TensorFlow/JAX/PyTorch)

**Pattern**: Start with keras3 for baseline, migrate to torch for custom experiments.

### r-tensorflow Skill

**When to use r-tensorflow:**
- TensorFlow-specific deployment (SavedModel, TF Serving)
- Infrastructure and production pipeline setup
- GPU configuration and optimization
- Integration with TensorFlow ecosystem

**Pattern**: Use torch for model development, r-tensorflow for deployment if TensorFlow required.

### learning-paradigms Skill

**When to use learning-paradigms:**
- Choosing between supervised, self-supervised, few-shot learning
- Data scarcity strategies
- Meta-learning approaches

**Pattern**: Use learning-paradigms for conceptual guidance, implement with torch.

## Performance Optimization

### GPU Best Practices

```r
# 1. Move model and data to GPU once
model$to(device = "cuda")

# 2. Keep data on GPU during training
coro::loop(for (batch in train_dl) {
  x <- batch$x$to(device = "cuda")
  y <- batch$y$to(device = "cuda")
  # ... training ...
})

# 3. Use pin_memory in dataloader (faster CPU→GPU transfer)
dl <- dataloader(dataset, batch_size = 32, pin_memory = TRUE)

# 4. Increase batch size for better GPU utilization
# Try largest batch that fits in GPU memory

# 5. Use cudnn benchmark for consistent input sizes
torch_backends_cudnn_benchmark_set(TRUE)
```

### Memory Management

```r
# Clear GPU cache
if (cuda_is_available()) {
  cuda_empty_cache()
}

# Detach tensors from computation graph
predictions <- model(x)$detach()

# Use with_no_grad() during inference
with_no_grad({
  predictions <- model(x)
})

# Delete large tensors explicitly
rm(large_tensor)
gc()  # R garbage collection
```

### DataLoader Optimization

```r
# Parallel data loading (not on Windows)
if (.Platform$OS.type != "windows") {
  dl <- dataloader(
    dataset,
    batch_size = 32,
    shuffle = TRUE,
    num_workers = 4,      # parallel workers
    pin_memory = TRUE     # faster GPU transfer
  )
} else {
  # Windows: use num_workers = 0
  dl <- dataloader(dataset, batch_size = 32, shuffle = TRUE, num_workers = 0)
}
```

## Troubleshooting

### Common Issues

**1. CUDA out of memory**
```r
# Solutions:
# - Reduce batch size
# - Use gradient accumulation
# - Clear cache: cuda_empty_cache()
# - Use mixed precision training
```

**2. Gradient explosion/vanishing**
```r
# Solutions:
# - Gradient clipping: nn_utils_clip_grad_norm_(model$parameters, max_norm = 1.0)
# - Use ReLU/Leaky ReLU activations
# - Batch normalization
# - Proper weight initialization
```

**3. DataLoader iteration errors**
```r
# Always use coro::loop() for dataloader iteration
library(coro)
coro::loop(for (batch in dl) {
  # ... training ...
})
```

**4. Indexing confusion (R vs Python)**
```r
# R uses 1-based indexing
x[1, ]      # first row in R
x[[1]]      # first element in list

# torch tensors use R-style indexing
tensor[1, ]  # first row
```

**5. Device mismatch errors**
```r
# Ensure model and data on same device
model$to(device = device)
x <- x$to(device = device)
y <- y$to(device = device)
```

## Supporting Files

### Examples
Complete working examples demonstrating torch patterns:
- [examples/audio-classification-torch.md](examples/audio-classification-torch.md) - CNN for audio spectrograms
- [examples/text-classification-lstm.md](examples/text-classification-lstm.md) - LSTM for NLP
- [examples/transfer-learning-finetuning.md](examples/transfer-learning-finetuning.md) - Fine-tuning pretrained models
- [examples/custom-loss-function.md](examples/custom-loss-function.md) - Custom loss implementation
- [examples/custom-training-loop-advanced.md](examples/custom-training-loop-advanced.md) - Advanced training patterns

### References
Deep-dive technical documentation:
- [references/nn-modules-reference.md](references/nn-modules-reference.md) - Complete nn_module patterns
- [references/optimization-and-performance.md](references/optimization-and-performance.md) - Performance tuning guide
- [references/torch-vs-keras-comparison.md](references/torch-vs-keras-comparison.md) - Detailed framework comparison

### Templates
Ready-to-use code templates:
- [templates/basic-model-template.R](templates/basic-model-template.R) - Minimal working model
- [templates/custom-training-template.R](templates/custom-training-template.R) - Complete training pipeline

## Best Practices Summary

✅ **DO:**
- Always zero gradients: `optimizer$zero_grad()`
- Use `model$train()` before training, `model$eval()` before evaluation
- Use `with_no_grad({...})` during evaluation
- Set device once and reuse
- Use `coro::loop()` for dataloader iteration
- Clip gradients for RNN/LSTM training
- Use `requires_grad_(FALSE)` to freeze layers
- Clear GPU cache periodically with `cuda_empty_cache()`

❌ **DON'T:**
- Forget to zero gradients (they accumulate!)
- Apply softmax before `nn_cross_entropy_loss()` (it's built-in)
- Use Python-style 0-based indexing (R is 1-based)
- Ignore device mismatches between model and data
- Use large batch sizes without gradient accumulation
- Mix training and evaluation without `model$train()`/`model$eval()`

## Resources

- **Official documentation**: https://torch.mlverse.org
- **Package manual**: https://mlverse.r-universe.dev/torch/doc/manual.html
- **Official book**: "Deep Learning and Scientific Computing with R torch"
- **Book materials**: https://mlverse.github.io/torchbook_materials/
- **GitHub**: https://github.com/mlverse/torch
- **Examples**: https://torch.mlverse.org/examples/

## Quick Reference Card

```r
# Tensors
x <- torch_tensor(data)
x$to(device = "cuda")
x$view(c(batch, -1))

# Model
model <- nn_module("MyNet", initialize = ..., forward = ...)
model$train()  # training mode
model$eval()   # evaluation mode

# Training
optimizer$zero_grad()
loss$backward()
optimizer$step()

# Gradient control
with_no_grad({...})
param$requires_grad_(FALSE)
nn_utils_clip_grad_norm_(params, max_norm)

# DataLoader
dl <- dataloader(dataset, batch_size, shuffle = TRUE)
coro::loop(for (batch in dl) {...})

# Device
device <- if (cuda_is_available()) "cuda" else "cpu"
```
