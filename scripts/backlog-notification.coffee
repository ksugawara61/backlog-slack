# Description:
#   Backlog to Slack
#
# Commands:
#   None

backlogUrl = 'https://k2o.backlog.jp/'

module.exports = (robot) ->
  robot.router.post "/room/:room", (req, res) ->
    { room } = req.params
    { body } = req
    try

      switch body.type
          when 1
              label = '課題の追加'
          when 2, 3
              # 「更新」と「コメント」は実際は一緒に使うので、一緒に。
              label = '課題の更新'
          when 5
              label = 'wikiの追加'
          when 6
              label = 'wikiの更新'
          when 8
              label = 'ファイルの追加'
          when 9
              label = 'ファイルの更新'
          else
              # 課題関連以外はスルー

      # 投稿メッセージを整形
      url = "#{backlogUrl}view/#{body.project.projectKey}-#{body.content.key_id}"
      if body.content.comment?.id?
          url += "#comment-#{body.content.comment.id}"

      message = "*Backlog #{label}*\n"
      message += "[#{body.project.projectKey}-#{body.content.key_id}] - "
      message += "#{body.content.summary} _by #{body.createdUser.name}_\n>>> "
      if body.content.comment?.content?
          message += "#{body.content.comment.content}\n"
      message += "#{url}"

      # Slack に投稿
      if message?
          robot.messageRoom room, message
          res.end "OK"
      else
          robot.messageRoom room, "Backlog integration error."
          res.end "Error"
    catch error
      robot.send
      res.end "Error"
