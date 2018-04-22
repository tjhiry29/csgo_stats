defmodule CsgoStats.Utils.ShareCode do
  @dictionary "ABCDEFGHJKLMNOPQRSTUVWXYZabcdefhijkmnopqrstuvwxyz23456789"
  @code_regex ~r/steam:\/\/rungame\/[0-9]+\/[0-9]+\/\+csgo_download_match%20CSGO-([A-Za-z0-9]+)-([A-Za-z0-9]+)-([A-Za-z0-9]+)-([A-Za-z0-9]+)-([A-Za-z0-9]+)/

  def is_share_code(code) do
    Regex.match?(
      @code_regex,
      code
    )
  end

  def get_code_chunks(code) do
    [_full_code | chunks] = Regex.run(@code_regex, code)
    chunks
  end

  def decode_share_code(code) do
    if is_share_code(code) do
      dict_length = String.length(@dictionary)
      dictionary = String.graphemes(@dictionary)

      dictionary_index = fn dictionary, char ->
        Enum.find_index(dictionary, fn c -> c == char end)
      end

      big =
        code
        |> get_code_chunks()
        |> Enum.join("")
        |> String.graphemes()
        |> Enum.reverse()
        |> Enum.reduce(0, fn char, acc ->
          acc * dict_length + dictionary_index.(dictionary, char)
        end)

      <<token_id::16, outcome_id::64, match_id::64, 0::size(1)>> = <<big::little-145>>

      {match_id, outcome_id, token_id}
    end
  end
end
