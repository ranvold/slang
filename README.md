# README

- Make sure that you have ruby 3.3.0 and postgresql

To install:
1. git clone git@github.com:ranvold/slang.git
2. Move to the directory project
3. use command: bundle install

Then db preparing:
```
bin/rails db:setup
```
Then compile assets:
```
bin/rails tailwindcss:build
```
Finally, start the server and check localhost:3000:
```
bin/rails server
```
