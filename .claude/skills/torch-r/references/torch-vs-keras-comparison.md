# torch vs keras3 - Detailed Framework Comparison

Comprehensive guide to choosing between torch and keras3 for deep learning in R.

## Quick Decision Matrix

| Criterion | Use torch | Use keras3 |
|-----------|-----------|------------|
| **Primary goal** | Research, experimentation, custom models | Production, rapid prototyping |
| **Control level needed** | Maximum (every detail) | High-level (sensible defaults) |
| **Training loop** | Custom loops, gradient manipulation | Built-in fit() with callbacks |
| **Model architecture** | Dynamic, research models | Standard architectures (ResNet, etc.) |
| **Learning curve** | Steeper (more explicit) | Gentler (more abstractions) |
| **Code verbosity** | More verbose | More concise |
| **Debugging** | Explicit control over every step | Higher-level debugging |
| **Deployment** | R-specific or via reticulate | Multi-backend (TF/JAX/PyTorch) |
| **PyTorch compatibility** | Direct (LibTorch C++) | Via backend only |

## Detailed Comparison

### 1. Philosophy & Design

**torch**
- **Low-level, explicit control**: You write every step of training
- **Imperative style**: Define-by-run (dynamic computation graphs)
- **Research-first**: Maximum flexibility for experiments
- **PyTorch heritage**: Direct port of PyTorch philosophy to R

```r
# torch: Explicit training loop
for (epoch in 1:num_epochs) {
  coro::loop(for (batch in train_dl) {
    optimizer$zero_grad()           # Manual gradient zeroing
    output <- model(batch$x)        # Forward pass
    loss <- loss_fn(output, batch$y)
    loss$backward()                 # Manual backward
    optimizer$step()                # Manual parameter update
  })
}
```

**keras3**
- **High-level, convenience-first**: Abstractions hide complexity
- **Declarative style**: Define-and-run (though backends differ)
- **Production-first**: Fast path from prototype to deployment
- **Keras heritage**: Multi-backend high-level API

```r
# keras3: One-line training
history <- model |> fit(
  train_data,
  epochs = num_epochs,
  validation_data = val_data,
  callbacks = list(early_stopping, checkpointer)
)
```

### 2. Model Definition

**torch: nn_module**
```r
library(torch)

my_model <- nn_module(
  "MyModel",

  # Constructor
  initialize = function(input_dim, hidden_dim, output_dim) {
    self$fc1 <- nn_linear(input_dim, hidden_dim)
    self$fc2 <- nn_linear(hidden_dim, output_dim)
    self$relu <- nn_relu()
    self$dropout <- nn_dropout(0.3)
  },

  # Forward pass - explicit control
  forward = function(x) {
    x |>
      self$fc1() |>
      self$relu() |>
      self$dropout() |>
      self$fc2()
  }
)

model <- my_model(784, 128, 10)
```

**Pros:**
- Full control over forward pass logic
- Can add conditional logic, loops, dynamic behavior
- Easy to debug (step through forward pass)
- Transparent architecture

**Cons:**
- More boilerplate code
- Must handle training/eval mode manually (`model$train()`, `model$eval()`)

---

**keras3: Functional or Sequential API**
```r
library(keras3)

# Sequential API (simplest)
model <- keras_model_sequential(input_shape = c(784)) |>
  layer_dense(128, activation = "relu") |>
  layer_dropout(0.3) |>
  layer_dense(10, activation = "softmax")

# Functional API (more flexible)
inputs <- layer_input(shape = c(784))
outputs <- inputs |>
  layer_dense(128, activation = "relu") |>
  layer_dropout(0.3) |>
  layer_dense(10, activation = "softmax")

model <- keras_model(inputs, outputs)
```

**Pros:**
- Concise, readable code
- Automatic training/eval mode handling
- Built-in model summary, plotting
- Standard architectures available (resnet, efficientnet, etc.)

**Cons:**
- Less explicit control in forward pass
- Harder to add custom logic (though possible with subclassing)

### 3. Training Workflow

**torch: Manual Training Loop**
```r
library(torch)

# Full control over training
model$train()  # Set training mode

for (epoch in 1:num_epochs) {
  train_loss <- 0

  coro::loop(for (batch in train_dl) {
    # Manual forward-backward
    optimizer$zero_grad()
    output <- model(batch$x$to(device = device))
    loss <- criterion(output, batch$y$to(device = device))
    loss$backward()

    # Optional: gradient clipping, modification
    nn_utils_clip_grad_norm_(model$parameters, max_norm = 1.0)

    optimizer$step()
    train_loss <- train_loss + loss$item()
  })

  # Manual validation
  model$eval()
  with_no_grad({
    # validation code
  })
  model$train()  # Back to training mode

  cat(sprintf("Epoch %d: Loss = %.4f\n", epoch, train_loss))
}
```

**Pros:**
- Complete control: modify gradients, implement custom updates
- Easy to add complex logic (e.g., multi-task learning)
- Transparent debugging
- Custom metrics, logging, checkpointing

**Cons:**
- Verbose (must write boilerplate)
- Easy to forget steps (zero gradients, train/eval mode)
- Manual metric tracking

---

**keras3: fit() with Callbacks**
```r
library(keras3)

# Compile model
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = loss_sparse_categorical_crossentropy(),
  metrics = c("accuracy")
)

# Train with fit()
history <- model |> fit(
  x = train_x,
  y = train_y,
  epochs = num_epochs,
  batch_size = 32,
  validation_split = 0.2,
  callbacks = list(
    callback_early_stopping(patience = 5),
    callback_model_checkpoint("best_model.keras", save_best_only = TRUE),
    callback_reduce_lr_on_plateau()
  )
)

# Automatic training/validation loop, checkpointing, early stopping!
```

**Pros:**
- Minimal code for standard workflows
- Built-in callbacks (early stopping, checkpointing, LR scheduling)
- Automatic train/val split
- Progress bars, history tracking

**Cons:**
- Less control over training loop details
- Custom training logic requires custom training loops (more complex)
- Harder to implement non-standard training (GANs, RL, meta-learning)

### 4. Custom Components

**torch: Custom Loss Functions**
```r
# Custom loss as nn_module
focal_loss <- nn_module(
  "FocalLoss",

  initialize = function(alpha = 1, gamma = 2) {
    self$alpha <- alpha
    self$gamma <- gamma
  },

  forward = function(inputs, targets) {
    ce <- nnf_cross_entropy(inputs, targets, reduction = "none")
    pt <- torch_exp(-ce)
    focal <- self$alpha * (1 - pt)^self$gamma * ce
    return(focal$mean())
  }
)

# Use like any loss function
criterion <- focal_loss(alpha = 1, gamma = 2)
loss <- criterion(predictions, targets)
```

**Straightforward**: Just implement `forward()`.

---

**keras3: Custom Loss Functions**
```r
# Custom loss as function
focal_loss <- function(alpha = 1, gamma = 2) {
  function(y_true, y_pred) {
    ce <- loss_sparse_categorical_crossentropy(y_true, y_pred)
    pt <- exp(-ce)
    focal <- alpha * (1 - pt)^gamma * ce
    mean(focal)
  }
}

# Compile with custom loss
model |> compile(
  optimizer = optimizer_adam(),
  loss = focal_loss(alpha = 1, gamma = 2)
)
```

**Also straightforward**, but must work with keras backend tensors.

### 5. Custom Layers

**torch: Custom Layers**
```r
attention_layer <- nn_module(
  "AttentionLayer",

  initialize = function(hidden_dim) {
    self$attention_weights <- nn_linear(hidden_dim, 1)
  },

  forward = function(x) {
    # x: [batch, seq_len, hidden_dim]
    scores <- self$attention_weights(x)$squeeze(3)
    weights <- nnf_softmax(scores, dim = 2)
    weighted <- x * weights$unsqueeze(3)
    output <- weighted$sum(dim = 2)
    return(output)
  }
)

# Use in model
self$attention <- attention_layer(256)
```

**Transparent**: Implement `initialize()` and `forward()`.

---

**keras3: Custom Layers**
```r
AttentionLayer <- new_layer_class(
  "AttentionLayer",

  initialize = function(hidden_dim, ...) {
    super$initialize(...)
    self$attention_weights <- layer_dense(1)
  },

  call = function(x) {
    # x: [batch, seq_len, hidden_dim]
    scores <- self$attention_weights(x) |> op_squeeze(axis = -1)
    weights <- op_softmax(scores, axis = -1)
    weights <- op_expand_dims(weights, axis = -1)
    weighted <- x * weights
    output <- op_sum(weighted, axis = -2)
    output
  }
)

# Use in model
layer_attention <- AttentionLayer(hidden_dim = 256)
```

**More API surface**: Must use `op_*` functions (backend-agnostic operations).

### 6. Data Loading

**torch: Dataset & DataLoader**
```r
library(torch)

# Custom dataset
my_dataset <- dataset(
  "MyDataset",

  initialize = function(x, y) {
    self$x <- x
    self$y <- y
  },

  .getitem = function(i) {
    list(x = self$x[i, ], y = self$y[i])
  },

  .length = function() {
    nrow(self$x)
  }
)

# DataLoader with batching, shuffling
ds <- my_dataset(train_x, train_y)
dl <- dataloader(ds, batch_size = 32, shuffle = TRUE)

# Iterate
coro::loop(for (batch in dl) {
  # batch$x, batch$y
})
```

**Flexible**: Custom logic in `.getitem()` (e.g., on-the-fly augmentation).

---

**keras3: Keras Datasets or tf.data**
```r
library(keras3)

# Option 1: In-memory (simple)
model |> fit(x = train_x, y = train_y, batch_size = 32, shuffle = TRUE)

# Option 2: tf_dataset (more powerful)
dataset <- tensor_slices_dataset(list(train_x, train_y)) |>
  dataset_shuffle(buffer_size = 1000) |>
  dataset_batch(32) |>
  dataset_prefetch(1)

model |> fit(dataset, epochs = 10)
```

**Simpler for standard cases**, more complex for custom preprocessing.

### 7. GPU Support

**torch**
```r
device <- if (cuda_is_available()) "cuda" else "cpu"

model$to(device = device)

# Move data to GPU in training loop
coro::loop(for (batch in train_dl) {
  x <- batch$x$to(device = device)
  y <- batch$y$to(device = device)
  # ...
})
```

**Manual**: You control device placement explicitly.

---

**keras3**
```r
# Automatic GPU detection
# keras3 automatically uses GPU if available
# No manual device management needed

model |> fit(train_x, train_y, epochs = 10)
# Automatically runs on GPU if available
```

**Automatic**: keras3 handles device placement.

### 8. Transfer Learning

**torch**
```r
# Load pretrained (if available)
pretrained_model <- my_pretrained_net()

# Freeze early layers
for (param in pretrained_model$conv1$parameters) {
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

**Explicit control** over which layers to freeze/train.

---

**keras3**
```r
# Load pretrained model
base_model <- application_resnet50(
  weights = "imagenet",
  include_top = FALSE,
  input_shape = c(224, 224, 3)
)

# Freeze base
freeze_weights(base_model)

# Add custom head
inputs <- layer_input(shape = c(224, 224, 3))
outputs <- inputs |>
  base_model() |>
  layer_global_average_pooling_2d() |>
  layer_dense(num_classes, activation = "softmax")

model <- keras_model(inputs, outputs)

# Compile and train (automatically skips frozen layers)
model |> compile(optimizer = optimizer_adam(), loss = "sparse_categorical_crossentropy")
model |> fit(train_x, train_y, epochs = 10)
```

**Simpler API** for standard transfer learning workflows.

### 9. Debugging

**torch**
```r
# Explicit forward pass - easy to debug
x <- torch_randn(c(2, 10))
output <- model(x)

# Check intermediate outputs
x_after_fc1 <- model$fc1(x)
x_after_relu <- model$relu(x_after_fc1)
# ...

# Check gradients
loss$backward()
print(model$fc1$weight$grad)  # Explicit gradient access
```

**Advantage**: Step through forward/backward passes easily.

---

**keras3**
```r
# Use model.predict() or submodels for intermediate outputs
intermediate_model <- keras_model(
  inputs = model$input,
  outputs = model$layers[[3]]$output
)
intermediate_output <- predict(intermediate_model, x)

# Gradient access requires custom training loops
```

**Less direct** access to internals, but higher-level debugging tools available.

### 10. When to Use Each

## Use torch when:

✅ **Research & experimentation**
- Implementing novel architectures from papers
- Testing new training algorithms
- Custom gradient manipulation (e.g., gradient reversal layers)

✅ **Maximum control needed**
- Non-standard training loops (GANs, RL, meta-learning)
- Dynamic models (architecture changes during training)
- Fine-grained debugging and introspection

✅ **PyTorch ecosystem**
- Porting PyTorch models to R
- Using PyTorch pretrained models
- Collaborating with PyTorch users

✅ **Learning deep learning internals**
- Understanding backpropagation deeply
- Educational contexts
- Building intuition for neural networks

## Use keras3 when:

✅ **Production & deployment**
- Standard architectures (ResNet, EfficientNet, BERT, etc.)
- Rapid prototyping and iteration
- Time-to-model is critical

✅ **High-level workflows**
- fit() with callbacks is sufficient
- Standard data augmentation
- Transfer learning from standard models

✅ **Multi-backend flexibility**
- Want to switch between TensorFlow/JAX/PyTorch backends
- Leveraging keras ecosystem (keras-cv, keras-nlp)

✅ **Team collaboration**
- Non-experts need to maintain code
- Standardized ML pipeline
- Less deep learning expertise available

## Hybrid Approach

Can you use both? **Yes!**

```r
# Use keras3 for standard components
base_model <- application_resnet50(
  weights = "imagenet",
  include_top = FALSE
)

# Extract features with keras3
features <- base_model |> predict(images)

# Use torch for custom downstream model
torch_model <- my_custom_torch_head()
```

## Summary

| Aspect | torch | keras3 |
|--------|-------|--------|
| **Code length** | Longer (explicit) | Shorter (concise) |
| **Flexibility** | Maximum | High but bounded |
| **Learning curve** | Steeper | Gentler |
| **Research** | ✅ Excellent | ⚠️ Limited |
| **Production** | ⚠️ More work | ✅ Excellent |
| **Debugging** | ✅ Transparent | ⚠️ Higher-level |
| **Community** | PyTorch (Python) | Keras (multi-language) |
| **Pretrained models** | Limited in R | ✅ Extensive |
| **Custom training** | ✅ Native | ⚠️ Requires workarounds |

## Conclusion

- **torch**: Choose when you need full control, research flexibility, or PyTorch compatibility
- **keras3**: Choose when you want rapid development, standard workflows, or production deployment

Both are excellent frameworks - the choice depends on your specific use case, team expertise, and project requirements.
