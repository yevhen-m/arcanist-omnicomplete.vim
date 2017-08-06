# arcanist-omnicomplete.vim

Completion for reviewers in `arcanistdiff` buffers.

### Installation and usage

This plugin:

- depends on `'solarnz/arcanist.vim'` plugin.
- requires vim with python support

Set these variables in your `vimrc` file:

- `g:conduit_api_url` -- **absolute** url of the conduit's `user` api endpoint
   (path should be something like `/api/user.query`)
- `g:conduit_api_token` -- your conduit's api token

Now when you edit an `arcanistdiff` buffer, you can complete reviewers with
`<C-x><C-o>` in `INSERT` mode.
