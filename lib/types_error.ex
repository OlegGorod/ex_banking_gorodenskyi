defmodule ExBanking.TypesError do
  @type error_tuple ::
          {:error,
           :wrong_arguments
           | :not_enough_money
           | :sender_does_not_exist
           | :receiver_does_not_exist
           | :too_many_requests_to_user
           | :user_already_exists
           | :user_does_not_exist
           | :too_many_requests_to_user}
end


