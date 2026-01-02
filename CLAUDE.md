# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BetterAppgen is a Ruby gem that generates Rails 8 applications with an opinionated, production-ready stack. It creates apps with Solid Stack (Cache, Queue, Cable backed by PostgreSQL), Vite 7 + Tailwind CSS 4, multi-database architecture, UUID primary keys, and Docker support.

## Commands

```bash
# Install dependencies
bin/setup

# Run tests
bundle exec rspec

# Run a single test file
bundle exec rspec spec/configuration_spec.rb

# Run linter
bundle exec rubocop

# Auto-fix linting issues
bundle exec rubocop -A

# Test the CLI locally
bundle exec bin/better_appgen new test-app --skip-docker

# Check dependencies
bundle exec bin/better_appgen check
```

## Architecture

### Entry Points
- `exe/better_appgen` - CLI executable
- `lib/better_appgen.rb` - Main module, loads all components

### Core Components
- `lib/better_appgen/cli.rb` - Thor-based CLI with `new`, `check`, `version` commands
- `lib/better_appgen/configuration.rb` - Immutable config object, validates app name, ports, locale
- `lib/better_appgen/app_generator.rb` - Orchestrator that runs generators in sequence
- `lib/better_appgen/dependency_checker.rb` - Validates Ruby, Rails, Node, Yarn, Git, PostgreSQL versions

### Generators (`lib/better_appgen/generators/`)
Each generator inherits from `Base` and implements `generate!`:
- `rails_app.rb` - Creates base Rails app with `rails new`
- `gemfile.rb` - Adds gems (solid_cache, solid_queue, solid_cable, vite_rails, etc.)
- `database.rb` - Multi-database config (primary, cache, queue, cable)
- `solid_stack.rb` - Solid Cache/Queue/Cable migrations
- `vite.rb` - Vite + Tailwind CSS + Stimulus setup
- `home_controller.rb` - HomeController with root route
- `locale.rb` - i18n configuration
- `docker.rb` - Docker development environment
- `simple_form.rb` - Optional SimpleForm with Tailwind

### Templates (`lib/better_appgen/templates/`)
ERB templates organized by destination path. Access config values via `@config` binding.

## Key Patterns

- **Bundler isolation**: Use `Bundler.with_unbundled_env` when running shell commands that need system gems (rails, yarn)
- **Config access in templates**: Templates receive `@config` with methods like `app_name`, `app_name_pascal`, `rails_port`, `vite_port`, `locale`, `timezone`
- **Locale handling**: Only `en` and `it` have translation templates; other locales trigger a warning

## Supported Locales
en, it, de, fr, es, pt, nl, pl, ru, ja, zh (only en/it include translation files)

## Commit Convention
Use conventional commits format:
- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation changes
- `refactor:` code refactoring
- `test:` adding/updating tests
- `chore:` maintenance tasks
