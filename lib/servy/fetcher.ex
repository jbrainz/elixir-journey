defmodule Servy.Fetcher do
  def async(func) do
    caller = self()
    spawn(fn -> send(caller, {self(), :result,  func.()}) end)
  end

  def get_results(pid) do
      receive do
        {^pid , :result, response} -> response
      after 2000 -> raise "Timed out!"
    end
  end
end
