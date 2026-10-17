## Summary

<!-- What does this PR do, and why? Link related issues: "Closes #123" -->

## Type of change

- [ ] Bug fix
- [ ] New feature
- [ ] Refactor / code cleanup
- [ ] Documentation
- [ ] Tests only
- [ ] Build / CI / tooling

## Screenshot(s) — REQUIRED for UI changes

> Delete this section only if the PR touches **no** UI. Any PR with a visual
> change must attach at least one before it can be reviewed.

| Before | After |
| ------ | ----- |
| <!-- image --> | <!-- image --> |

**Screenshots recorded on:** <!-- e.g. Android emulator – Pixel 7, API 35 -->

<!-- Paste images directly into the PR body, e.g.:
![before](https://github.com/user-attachments/assets/xxxx)
![after](https://github.com/user-attachments/assets/yyyy)
-->

- [ ] I have attached at least one screenshot of the changed UI
- [ ] I have verified the change on both light/dark or both roles (client / PT) where applicable
- [ ] Empty / loading / error states shown (if relevant)

## Testing

<!-- How was this verified? Manual steps, `flutter test`, device name, etc. -->

- [ ] `dart format --set-exit-if-changed .`
- [ ] `dart analyze` (no new errors or warnings)
- [ ] `flutter test`
- [ ] Manually tested on device/emulator: <!-- steps -->

## Checklist

- [ ] No hardcoded secrets, API keys, or credentials added
- [ ] No generated/build output committed (`build/`, `android/build/`, `.dart_tool/`)
- [ ] New/changed public widgets documented or self-explanatory
- [ ] Migrations included if schema changed (`supabase/migrations/`)
- [ ] Breaking changes described above and in the PR title (`!:` prefix if applicable)
