# Semantic Guideline

### Types
- `feat` — new feature for the user
- `fix` — bug fix for the user
- `docs` — documentation changes
- `style` — formatting, missing semi colons, etc.
- `refactor` — refactoring production code
- `test` — adding missing tests, refactoring tests
- `chore` — updating grunt tasks, nothing that an external user would see

<br>

## Branch Names
### Format
```
<name>/<type>/<task_description>
```

### Example
```
john/docs/setup-instructions
john-smith/feat/user-authentication
```

<br>

## Commit Messages
### Format
```
<type>(<optional scope>): <description>
```

### Example
```
feat: add login page
fix(button): logout user
```

<br>

## Pull Requests (Title)
### Format
```
<type>(<optional scope>): <brief description>
```

### Example
```
feat: add user authentication
fix(api): resolve 404 error on user fetch
docs: update README with setup instructions
```

<br>

## Pull Requests (Description)
### Format
```
## Summary
A brief description of the changes made.

## Changes Made
* Bullet point list of changes made

## Screenshots (if applicable)
Include screenshots of the changes in action, if applicable.
```

### Example
```
## Summary
Added user authentication feature to allow users to securely log in and access their accounts.

## Changes Made
* Created login and registration forms
* Integrated authentication API
* Added JWT token handling
* Updated navigation to reflect authentication state

## Screenshots (if applicable)
```
