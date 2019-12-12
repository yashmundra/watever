defmodule Utils do
    @base 62
    @base_chars "1234567890qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"

    def change_base(num), do: change_base(num, "")
    
    #remainders prepended make the base-62 representation
    defp change_base(num, str) do
        case num do
            0 -> str
            _ ->change_base(div(num, @base), String.at(@base_chars, rem(num, @base)) <> str) 
        end
    end 

    def get_hashtags(left, right, list) do
        if left == right do
            list
        else
            get_hashtags(left + 1, right, ["#" <> change_base(left) | list])
        end
    end

    def get_mentions(left, right, list) do
        if left == right do
            list
        else
            get_mentions(left + 1, right, ["@" <> change_base(left) | list])
        end
    end

    def get_tweets(left, right, hashtags, hl, mentions, ml, list, has_hashtag, has_mention, hashtag_index, mention_index) do
        if left == right do
            list
        else
            tweet_str = change_base(left)    
            {tweet_str, hashtag_index} = if has_hashtag do             
                {tweet_str <> " " <> Enum.at(hashtags, hashtag_index), (hashtag_index + 1) |> rem(hl) }
            else
                {tweet_str, hashtag_index}
            end
            
            {tweet_str, mention_index} = if has_mention do                
                {tweet_str <> " " <> Enum.at(mentions, mention_index), (mention_index + 1) |> rem(ml) }
            else
                {tweet_str, mention_index}
            end
            left = left + 1
            num = :rand.uniform(10)
            has_hashtag = if(rem(num, 2) == 0) do !has_hashtag else has_hashtag end
            has_mention = if(rem(num, 2) != 0) do !has_mention else has_mention end
            get_tweets(left, right, hashtags, hl, mentions, ml, [ tweet_str| list], has_hashtag, has_mention, hashtag_index, mention_index)
        end
    end
    
end