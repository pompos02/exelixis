defmodule Core.Accounts.UserNotifier do
  import Swoosh.Email

  # Delivers the email using the application mailer.
  # The mailer module is passed as a parameter to allow flexibility
  # in which app handles email delivery.
  defp deliver(recipient, subject, body, mailer_module) do
    email =
      new()
      |> to(recipient)
      |> from({"Exelixi", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- mailer_module.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url, mailer_module \\ Auth.Mailer) do
    deliver(
      user.email,
      "Confirmation instructions",
      """

      ==============================

      Hi #{user.email},

      You can confirm your account by visiting the URL below:

      #{url}

      If you didn't create an account with us, please ignore this.

      ==============================
      """,
      mailer_module
    )
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url, mailer_module \\ Auth.Mailer) do
    deliver(
      user.email,
      "Reset password instructions",
      """

      ==============================

      Hi #{user.email},

      You can reset your password by visiting the URL below:

      #{url}

      If you didn't request this change, please ignore this.

      ==============================
      """,
      mailer_module
    )
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url, mailer_module \\ Auth.Mailer) do
    deliver(
      user.email,
      "Update email instructions",
      """

      ==============================

      Hi #{user.email},

      You can change your email by visiting the URL below:

      #{url}

      If you didn't request this change, please ignore this.

      ==============================
      """,
      mailer_module
    )
  end
end
