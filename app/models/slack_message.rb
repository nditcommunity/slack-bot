# Slack message templates built initially using the [Slack Block Kit Builder](https://api.slack.com/block-kit)
module SlackMessage
  module_function

  # constant for channel ids and descriptions for identity channels
  CHANNELS = {
    thirty_five_plus: {channel_id: "C070AHYHKHN", description: "for anyone 35 and older"},
    bipoc: {channel_id: "C06V26ZBMQA", description: "for anyone who identifies as BIPOC"},
    marginalized_genders: {channel_id: "C067HKZ219C", description: "not a cis dude? this channel's for you!"},
    nonbinary: {channel_id: "C06866GL9BN", description: "for nonbinary folks"},
    queer: {channel_id: "C067M825K6Z", description: "for LGBTQIA+ folks"},
    trans: {channel_id: "C068SG4F140", description: "for anyone who identifies as trans"},
    women: {channel_id: "C068GBV8V09", description: "for anyone who identifies as a woman"}
    physical_disability: {channel_id: "C074GQJMHN2", description: "for anyone with a physical disability"}
  }

  # Generates help message for identity channels
  #
  # @return [JSON] message content fitting Slack's block kit requirements
  def help_message
    [
      {
        type: "section",
        block_id: "help_message",
        text: {
          type: "mrkdwn",
          text: "*thirty_five_plus*: #{CHANNELS[:thirty_five_plus][:description]}
*bipoc:* #{CHANNELS[:bipoc][:description]}
*marginalized_genders:* #{CHANNELS[:marginalized_genders][:description]}
*nonbinary:* #{CHANNELS[:nonbinary][:description]}
*queer:* #{CHANNELS[:queer][:description]}
*trans:* #{CHANNELS[:trans][:description]}
*women:* #{CHANNELS[:women][:description]}
*physical_disability:* #{CHANNELS[:physical_disability][:description]}
"
        }
      }
    ]
  end

  # Generates the pair message for a pair of users
  #
  # @param pair [Array of Arrays of Strings] pairs of users, ex: [["U1234", "U2345"], ["U3456", "U4567"]]
  # @return [JSON] message content fitting Slack's block kit requirements
  def pair_message(pair:)
    pair_usernames = pair.map { |user| "<@#{user}>" }.to_sentence
    [
      {
        type: "section",
        block_id: "pair_introduction",
        text: {
          type: "mrkdwn",
          text: ":wave: Hi #{pair_usernames}! You've both been paired up for a coffee chat from <##{ENV["PAIRING_CHANNEL"]}>! Find a time to meet (Calendly is great for this) and have fun!"
        }
      }
    ]
  end

  # Generates a message to the mod channel
  #
  # @param user_id [String] slack user id of user sending message to mods
  # @param channel_id [String] slack channel id user is sending message from
  # @param channel_name [String] slack channel name where user initially reached out to /mods
  # @param text [String] text of message
  # @return [JSON] message content fitting Slack's block kit requirements
  def mod_message(user_id:, channel_id:, channel_name:, text:)
    [
      {
        type: "section",
        block_id: "mod_message",
        text: {
          type: "mrkdwn",
          text: "Message from <@#{user_id}>
in <##{channel_id}> (#{channel_name}):
#{text}"
        }
      }
    ]
  end
end
