# Dotfiles - Cross-Platform Development Environment

This repository contains cross-platform development environment configurations for consistent shell, git, and development tool settings.

## Repository Structure

- **Shell configurations**: bash, PowerShell profiles and aliases
- **Git configuration**: Global git settings and aliases
- **Development tools**: VS Code settings, terminal themes
- **Setup scripts**: Bootstrap scripts for new environment setup

## Platform Support

- **Windows**: PowerShell profiles, Windows-specific configurations
- **Linux/NixOS**: Bash configurations, Unix-style dotfiles
- **Cross-platform**: Git configuration, shared aliases and functions

## Configuration Guidelines

### File Organization:
- Separate platform-specific and shared configurations
- Use clear, descriptive names for configuration files
- Group related configurations logically
- Maintain backward compatibility when possible

### Code Quality:
- Include comments explaining configuration choices
- Use consistent formatting and conventions
- Follow platform-specific best practices
- Test configurations on target platforms

### Deployment:
- Provide automated setup scripts for new environments
- Support both manual and automated deployment
- Preserve existing configurations when possible
- Document platform-specific requirements

## Integration

- Works alongside NixOS configurations for Linux environments
- Complements nixos-tools for development workflow
- Provides consistent experience across development platforms
- Supports both local and remote development scenarios

Reference the nixos-tools repository for additional development and deployment automation.
