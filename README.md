# Build system updater
To run execute `upgrade-all.sh`, it will perform next steps:
   1. Pulls all repositories specified in `repositories.list` (only pulls and hard resets with clean if already pulled)
   2. Upgrade each pulled repository
   3. Commits and pushes changes found after upgrade (if any)

In case of repository failing, next step won't be executed.
All failed repositories will appear in according file in reports directory.
