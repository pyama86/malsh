# Malsh
*Mackerel Shepherd = malsh(マルシェ)*

[![Build Status](https://travis-ci.org/pyama86/malsh.svg)](https://travis-ci.org/pyama86/malsh)

[![Code Climate](https://codeclimate.com/github/pyama86/sac/badges/gpa.svg)](https://codeclimate.com/github/pyama86/sac)


### Mackerelの運用で便利な機能を提供します。

* 退役忘れホストの通知
* ロールに紐付いてないホストの通知
* 特定のホスト名やCPU、メモリ利用率での検索結果の通知

### 通知先
* Slack

## Installation

```ruby
gem install malsh
```

## Usage

```sh
$ export MACKEREL_APIKEY=xxxxxxxxxxxxxxxxxxxxxxxxxx

# 過去5分間メトリックの投稿がないホストを検知
$ malsh retire --subject 退役忘れホスト

# ロールに所属していないホストを検知
$ malsh maverick --subject 無所属ホスト

# 指定された単語がホスト名に含まれるホストを検知
$ malsh search --regex dev local$ --subject developmentホスト

# CPUとメモリの過去7日間の最高使用率が40%以下のホストをを検知
$ malsh search --past_date 7 --cpu 40 --memory 40 --subject 過去7日間のCPU、メモリがの最高使用率が40%以下
```

## options
* --slack-webhook or ENV["SLACK_WEBHOOK"]
 * slackのwebhookurlを指定するとslackに通知することができます。
* --slack-channel or ENV["SLACK_CHANNEL"]
 * slackの通知先チャネルを指定します。
* --slack-user or ENV["SLACK_USER"]
 * slackの通知ユーザーを指定します。
* --api-key or ENV["MACKEREL_APIKEY"]
 * mackerelのAPIキーを指定します。
* --subject
 * 通知のタイトルを指定します
* --invert-match
 * 除外したいホスト名を正規表現で指定します。
* --regex
 * 特定したいホスト名を正規表現で指定します。
* --invert-role
 * 除外したいロール名を`service:role`で指定します。

## Author
pyama86
