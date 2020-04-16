# telegram-bot-using-ruby
> This bot will notify you about new comments (feedbacks) on pull requests in your repository

[Link to telegram bot](https://t.me/microverse_pr_bot)
[Video of project presentation](https://www.loom.com/share/36462277a85a48caa879950cb8ff7521)

## Build with
- Ruby
- HTTParty
- telegram/bot lib
- GitHub API
- RSpec

## Screenshot of bot
![screenshot](./screenshot.png)

## Getting started
In order to use this Telegram Bot:

1. Open telegram find @microverse_pr_bot
2. Start a bot, it will ask you to use /auth command in which you need to provide your github username
3. Check if bot has saved your github username you can run /username command
4. Run /check command to check if there are new comments/feedbacks in your pull requests 

## Future plans
- Make /check commands running without user after specific time interval
- Make bot check updates based on time of comments creating rather than checking numbers of comments(feedbacks)
- Bot able to git pull requests link that was created by coding partner

## Commands available
1. /start - Starting a bot
2. /stop - Stopping a bot
3. /auth - Saves your GitHub username
4. /username - Give you username that you have provided to bot
6. /check - Checks if there are new feedbacks on your repos

## Authors

👤 **Azamat Nuriddinov**

- Github: [@bettercallazamat](https://github.com/bettercallazamat)
- Twitter: [@azamat_nuriddin](https://twitter.com/azamat_nuriddin)
- Linkedin: [Azamat Nuriddinov](https://www.linkedin.com/in/azamat-nuriddinov-57579868)

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

Feel free to submit a new suggestion > [issues page](issues/).

## Show your support

Give a ⭐️ if you like this project!
