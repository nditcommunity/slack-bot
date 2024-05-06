# Generates groups for both a groups and pairing channel
class CreateGroupsJob < ApplicationJob
  MIN_GROUP_SIZE = 2 # allows for a group of 3
  MAX_GROUP_SIZE = 4 # allows for a group of 3

  class << self
    # Checks if that date is a Monday. If it's the first Monday, it creates pairs; if it's an even week, it creates groups.
    def perform
      Rails.logger.info("Running CreateGroupsJob")
      date = Date.today
      if ENV["PAIRING_CHANNEL"].present?
        Rails.logger.info("It's the first Monday of the month! Generating pairs!")
        create_pairs
      end
    end

    # Gets the users from the pairing channel (stored as an environment variable), groups,
    # balances groups (so there isn't a group of 1), and starts the conversations
    def create_pairs
      members = Slack::Client.get_channel_users(channel_id: ENV["PAIRING_CHANNEL"])
      pairs = group_members(members: members, group_size: MIN_GROUP_SIZE)
      pairs = balance_pairs(pairs)
      start_conversations(groups: pairs, type: :pairing)
      Rails.logger.info("Started conversations with #{pairs.count} pairs")
    end

    # Randomizes the list of members, shifts (take the top) X members (where X is group_size), and returns the array
    #
    # @param members [Array of Strings] list of channel members, ex: ["U1234", "U2345", "U3456"]
    # @param group_size [Integer] in this context, maximum size of the group. Currently 2 or 4.
    # @return [Array of Array of Strings] groups of channel members, ex: [["U1234", "U2345"], ["U3456"]]
    def group_members(members:, group_size:)
      groups = []
      members.shuffle!
      groups << members.shift(group_size) while members.any?
      groups
    end

    # Balances the pair arrays to ensure that everyone get a group (no groups of 1)
    #
    # @param pairs [Array of Array of Strings] current groups of channel members, ex: [["U1234", "U2345"], ["U3456"]]
    # @return [Array of Array of Strings] balanced group of channel members, ex: [["U1234", "U2345", "U3456"]]
    def balance_pairs(pairs)
      if pairs.last.length == 1 # [[1,2][3]]
        pairs[-2] << pairs.last.pop # [[1,2,3][]]
        pairs.pop # [[1,2,3]]
      end
      pairs
    end

    # Starts up the conversations for each group
    #
    # @param groups [Array of Array of Strings] balanced groups of channel users
    # @param type [Symbol] group type so we send the right message. Currently either :pairing or :groups
    def start_conversations(groups:, type:)
      groups.each do |group|
        Slack::Client.create_conversation(group: group, type: type)
      end
    end
  end
end
