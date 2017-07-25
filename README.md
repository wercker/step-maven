# Wercker-maven

Wercker step to install maven and run a command.

## Example

```yaml
build:
  steps:
    - maven:
        command: compile
        version: 3.5.0
```

### Options

- `command` (required): maven task [install, build, compile].
- `version` (optional): maven 3 version to use.
