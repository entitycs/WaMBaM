---
description: Consolidate similar input handlers into one generic method to
  reduce code duplication
alwaysApply: true
---

When creating multiple similar input handler methods that accept a single value parameter and use the same logic, consolidate them into a single generic :onInput(name, inputValue) method. Use name to identify which ability is being handled.