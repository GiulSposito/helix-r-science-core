# torch-r Skill - PyTorch for R Deep Learning

Expert guidance for **torch**, the R interface to LibTorch (PyTorch C++ backend), providing maximum flexibility and explicit control over neural network design, training, and experimentation.

## Overview

This skill transforms Claude Code into a torch expert for deep learning in R, with comprehensive knowledge of:

- **Tensors & Autograd**: Multidimensional arrays and automatic differentiation
- **Neural Network Modules**: Custom architectures with `nn_module`
- **Training Workflows**: Manual training loops with full control
- **Domain Applications**: Computer vision, NLP, audio, time series
- **Advanced Patterns**: Custom losses, layers, gradient manipulation
- **Performance**: GPU acceleration, optimization strategies

## When to Use torch

### Perfect for:
- ✅ Research and experimentation
- ✅ Custom architectures and training procedures
- ✅ Maximum control over gradient computation
- ✅ PyTorch ecosystem integration
- ✅ Dynamic computation graphs
- ✅ Low-level deep learning understanding

### Consider keras3 instead for:
- ⚠️ Rapid prototyping with minimal code
- ⚠️ Standard architectures (ResNet, EfficientNet, etc.)
- ⚠️ Built-in `fit()` workflow sufficient
- ⚠️ Production deployment pipelines

See [references/torch-vs-keras-comparison.md](references/torch-vs-keras-comparison.md) for detailed comparison.

## Skill Structure

```
.claude/skills/torch-r/
├── SKILL.md (1,100 lines)             # Main skill with comprehensive guidance
│   ├── Core Concepts                   # Tensors, autograd, nn_module, training
│   ├── Domain Applications             # Vision, NLP, audio, time series
│   ├── Advanced Topics                 # Custom components, GPU, transfer learning
│   └── Best Practices                  # Patterns, optimization, troubleshooting
│
├── examples/ (2 files)                 # Complete working examples
│   ├── audio-classification-torch.md   # CNN for audio spectrograms
│   └── text-classification-lstm.md     # LSTM for NLP with attention
│
├── references/ (1 file)                # Deep-dive documentation
│   └── torch-vs-keras-comparison.md    # Detailed framework comparison
│
└── templates/ (1 file)                 # Ready-to-use templates
    └── basic-model-template.R          # Complete training pipeline
```

## Key Features

### 1. Core torch Concepts
- **Tensors**: Creation, manipulation, device management (CPU/GPU)
- **Autograd**: Automatic differentiation, gradient tracking
- **nn_module**: Custom neural network definition
- **Training loops**: Complete control over forward/backward passes
- **Datasets & DataLoaders**: Efficient data handling

### 2. Domain-Specific Patterns
- **Computer Vision**: CNN architectures for images
- **NLP**: LSTM/GRU with attention mechanisms
- **Time Series**: RNN-based forecasting
- **Audio**: Spectrogram classification

### 3. Advanced Techniques
- **Custom loss functions**: Implement any loss (focal, triplet, etc.)
- **Custom layers**: Build novel architectures
- **Gradient manipulation**: Clipping, custom updates
- **Transfer learning**: Freeze layers, fine-tuning
- **Multi-GPU training**: Data parallelism

### 4. Performance Optimization
- GPU best practices
- Memory management
- DataLoader optimization
- Profiling and debugging

## Skill Type

**Background Reference Skill** (`user-invocable: false`)

Claude automatically uses this skill when detecting:
- torch-related code or discussions
- Mentions of "torch", "torch em R", "PyTorch R"
- API patterns: `nn_module`, `nn_linear`, `torch_tensor`, `autograd`
- Deep learning tasks requiring custom control

## Quick Start Example

```r
library(torch)

# Define model
model <- nn_module(
  "SimpleNet",
  initialize = function(input_dim, hidden_dim, output_dim) {
    self$fc1 <- nn_linear(input_dim, hidden_dim)
    self$fc2 <- nn_linear(hidden_dim, output_dim)
    self$relu <- nn_relu()
  },
  forward = function(x) {
    x |> self$fc1() |> self$relu() |> self$fc2()
  }
)

# Training loop
model$train()
for (epoch in 1:num_epochs) {
  coro::loop(for (batch in train_dl) {
    optimizer$zero_grad()
    output <- model(batch$x)
    loss <- loss_fn(output, batch$y)
    loss$backward()
    optimizer$step()
  })
}
```

See [templates/basic-model-template.R](templates/basic-model-template.R) for a complete production-ready template.

## Documentation Resources

### Official torch for R
- **Main site**: https://torch.mlverse.org
- **Package manual**: https://mlverse.r-universe.dev/torch/doc/manual.html
- **Official book**: "Deep Learning and Scientific Computing with R torch"
- **Book materials**: https://mlverse.github.io/torchbook_materials/

### This Skill
- **Main skill**: [SKILL.md](SKILL.md) - Comprehensive guide
- **Examples**: [examples/](examples/) - Complete working examples
- **References**: [references/](references/) - Deep-dive documentation
- **Templates**: [templates/](templates/) - Ready-to-use code

## Key Patterns

### Model Definition Pattern
```r
my_model <- nn_module(
  "MyModel",
  initialize = function(...) {
    # Define layers in constructor
    self$layer1 <- nn_linear(...)
    self$layer2 <- nn_linear(...)
  },
  forward = function(x) {
    # Define forward pass
    x |> self$layer1() |> self$layer2()
  }
)
```

### Training Loop Pattern
```r
model$train()
coro::loop(for (batch in train_dl) {
  optimizer$zero_grad()   # Always zero gradients first!
  output <- model(batch$x)
  loss <- criterion(output, batch$y)
  loss$backward()
  optimizer$step()
})
```

### Evaluation Pattern
```r
model$eval()
with_no_grad({  # Disable gradient tracking
  coro::loop(for (batch in val_dl) {
    output <- model(batch$x)
    # Compute metrics
  })
})
```

## Integration with Other Skills

### r-deeplearning
Framework comparison and decision guidance for choosing between torch, keras3, and tensorflow.

### keras3
High-level API alternative for rapid prototyping and standard architectures.

### r-tensorflow
TensorFlow deployment and infrastructure when TensorFlow Serving required.

### learning-paradigms
Conceptual guidance for self-supervised, few-shot, and transfer learning approaches.

## torch Philosophy

torch follows the **PyTorch philosophy**:

1. **Explicit over implicit**: You write every step, full transparency
2. **Imperative, define-by-run**: Dynamic computation graphs
3. **Research-first**: Maximum flexibility for experimentation
4. **Pythonic/R-native**: Feels natural in the host language
5. **Debuggable**: Step through forward/backward passes easily

This makes torch ideal for:
- Implementing papers from scratch
- Experimenting with novel architectures
- Understanding deep learning internals
- Non-standard training procedures (GANs, RL, meta-learning)

## Common Use Cases

| Task | torch Approach |
|------|----------------|
| **Image Classification** | CNN with custom data augmentation |
| **Text Classification** | LSTM/GRU with attention mechanism |
| **Audio Classification** | CNN on mel-spectrograms |
| **Time Series Forecasting** | RNN/LSTM with custom loss |
| **Transfer Learning** | Fine-tune pretrained models |
| **Custom Architectures** | Implement from papers |
| **Research Experiments** | Full control over training |

## Best Practices Checklist

✅ **Always do:**
- Zero gradients before backward: `optimizer$zero_grad()`
- Set training mode: `model$train()` before training
- Set eval mode: `model$eval()` before evaluation
- Use `with_no_grad({...})` during inference
- Clip gradients for RNN/LSTM: `nn_utils_clip_grad_norm_(...)`
- Move model and data to same device

❌ **Never do:**
- Forget to zero gradients (they accumulate!)
- Apply softmax before `nn_cross_entropy_loss()` (built-in)
- Use 0-based indexing (R is 1-based!)
- Ignore device mismatches
- Skip `model$train()`/`model$eval()` mode switching

## Examples Included

### Audio Classification ([examples/audio-classification-torch.md](examples/audio-classification-torch.md))
Complete pipeline:
- Audio preprocessing (mel-spectrograms)
- Custom dataset for audio files
- CNN architecture for spectrograms
- Training, validation, and inference
- ~250 lines of documented code

### Text Classification with LSTM ([examples/text-classification-lstm.md](examples/text-classification-lstm.md))
Complete pipeline:
- Text preprocessing and vocabulary building
- LSTM with attention mechanism
- Custom dataset for sequences
- Training and inference functions
- ~300 lines of documented code

## Templates Included

### Basic Model Template ([templates/basic-model-template.R](templates/basic-model-template.R))
Production-ready template with:
- Configuration management
- Data loading (dataset + dataloader)
- Model definition (nn_module)
- Complete training loop
- Validation and metrics tracking
- Model checkpointing
- Logging and visualization setup
- Inference function
- ~300 lines, ready to customize

## torch vs keras3 Decision Matrix

| Criterion | torch | keras3 |
|-----------|-------|--------|
| **Control** | Maximum | High-level |
| **Code verbosity** | More verbose | More concise |
| **Learning curve** | Steeper | Gentler |
| **Research** | ✅ Excellent | Limited |
| **Production** | More work | ✅ Excellent |
| **Custom training** | ✅ Native | Requires workarounds |
| **Pretrained models** | Limited | ✅ Extensive |
| **Debugging** | ✅ Transparent | Higher-level |

See detailed comparison: [references/torch-vs-keras-comparison.md](references/torch-vs-keras-comparison.md)

## Installation

### Install torch for R
```r
install.packages("torch")

# First run will download LibTorch (may take a few minutes)
library(torch)

# Check installation
torch_tensor(c(1, 2, 3))

# Check CUDA (GPU support)
cuda_is_available()
cuda_device_count()
```

### GPU Support
torch automatically detects CUDA if available. No additional configuration needed.

```r
device <- if (cuda_is_available()) "cuda" else "cpu"
model$to(device = device)
```

## Related Skills

- **r-deeplearning**: General deep learning guidance (torch + keras3)
- **keras3**: High-level deep learning alternative
- **r-tensorflow**: TensorFlow deployment in R
- **learning-paradigms**: ML paradigm selection guide
- **r-bioacoustics**: Audio preprocessing (complements torch audio examples)
- **r-text-mining**: Text preprocessing (complements torch NLP examples)

## Contributing

To extend this skill:
1. Add new examples to `examples/` for domain-specific applications
2. Add new references to `references/` for deep-dive topics
3. Add new templates to `templates/` for common workflows
4. Update `SKILL.md` with new patterns and best practices

## Version

- **Current version**: 1.0.0
- **Last updated**: 2026-03-17
- **torch R package**: https://github.com/mlverse/torch
- **LibTorch version**: Automatically managed by torch package

## Quick Reference Card

```r
# Core Pattern
model <- nn_module("MyNet", initialize = ..., forward = ...)
model$to(device = device)

# Training Loop
model$train()
optimizer$zero_grad()
loss <- criterion(model(x), y)
loss$backward()
optimizer$step()

# Evaluation
model$eval()
with_no_grad({ predictions <- model(x) })

# Device Management
device <- if (cuda_is_available()) "cuda" else "cpu"
x$to(device = device)

# Gradient Control
nn_utils_clip_grad_norm_(model$parameters, max_norm = 1.0)
param$requires_grad_(FALSE)  # Freeze

# DataLoader
dl <- dataloader(dataset, batch_size, shuffle = TRUE)
coro::loop(for (batch in dl) {...})
```

---

**torch-r skill**: Maximum flexibility deep learning in R 🔥
