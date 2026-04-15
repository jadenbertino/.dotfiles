Run the check script and fix any issues found. Repeat until all checks pass.

**Note:** The check script runs the required `lint` and `typecheck` checks for changed workspaces.

## Usage

- `bash .claude/commands/check.sh` - Check working directory changes
- `bash .claude/commands/check.sh --branch` - Check branch changes from main

## Steps

1. Run `cd /workspaces/neon && bash .claude/commands/check.sh`
2. If the output contains "All checks passed", stop — you're done.
3. If the output contains "Some checks failed", analyze the error output to identify the specific TypeScript, lint, or type-check errors.
4. Fix all identified issues in the source files. If the check script itself is clearly out of date with the repo tooling, update it as part of the fix.
5. Go back to step 1.

## Fix rules

- Make the **smallest reasonable changes** to fix each error. Do not refactor unrelated code.
- **NEVER use `as any`** to silence type errors. Fix the actual type issue.
- **Do not add `eslint-disable-next-line`** — fix the underlying issue instead. If you believe a disable is genuinely necessary, **skip it for now** and keep going. After all other issues are resolved, present all cases where you think a disable is needed with your reasoning, and wait for permission before adding any.
- **NEVER use `as` to override type inference** unless the type system is genuinely wrong and there's no better option.
- Match the style and formatting of surrounding code.
- Preserve existing functionality — fixes should be minimal and targeted.

## Safety

- If you encounter the same error 3 times in a row without progress, **stop and report the issue** instead of looping forever.
- If a fix requires architectural changes or deleting/rewriting existing implementations, **stop and ask** instead of proceeding.
