defmodule NimiqAddress do
  require Logger
  @ccode "NQ"

  def decode_from_stake_data(data) do
    data
    |> :binary.decode_hex()
    |> case do
      data when byte_size(data) == 21 ->
        data
        |> binary_part(1, 20)
        |> to_user_friendly()

      _other ->
        {:error, :invalid_data}
    end
  end

  def decode_from_hex(hex) do
    hex
    |> :binary.decode_hex()
    |> to_user_friendly()
  end

  def to_user_friendly(bytes) do
    base32 = NimiqAddress.Base.encode32(bytes)
    iban_check = "00" <> ((98 - iban_check(base32 <> @ccode <> "00")) |> to_string())
    check = String.slice(iban_check, String.length(iban_check) - 2, 2)

    @ccode <> check <> base32
    |> String.codepoints()
    |> Stream.chunk_every(4)
    |> Stream.map(&Enum.join/1)
    |> Enum.reduce("", fn chunk, acc ->
      acc <> " " <> chunk
    end)
    |> String.trim()
  end

  defp iban_check(str) do
    num =
      str
      |> String.codepoints()
      |> Enum.map(fn c ->
        code = :binary.first(c)

        if code >= 48 and code <= 57 do
          c
        else
          code - 55 |> to_string()

        end
      end)
      |> Enum.join()


    iterate = Stream.iterate(0, &(&1 + 1))
    Enum.reduce_while(iterate, "", &reduce_iban_number(&1, &2, num))
    |> String.to_integer()
  end

  defp reduce_iban_number(i, acc, num) do
    if i < ceil(String.length(num) / 6) do
      acc =
        (acc <> String.slice(num, i * 6, 6))
        |> String.to_integer()
        |> rem(97)
        |> to_string()

      {:cont, acc}
    else
      {:halt, acc}
    end
  end
end
