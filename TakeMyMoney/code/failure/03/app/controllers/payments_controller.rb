#---
# Excerpted from "Take My Money",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/nrwebpay for more book information.
#---
class PaymentsController < ApplicationController

  def show
    @reference = params[:id]
    @payment = Payment.find_by(reference: @reference)
  end

  def create
    workflow = run_workflow(params[:payment_type])
    if workflow.success
      redirect_to workflow.redirect_on_success_url ||
          payment_path(id: @reference || workflow.payment.reference)
    else
      redirect_to shopping_cart_path
    end
  end

  private def run_workflow(payment_type)
    case payment_type
    when "paypal" then paypal_workflow
    else
      stripe_workflow
    end
  end

  private def paypal_workflow
    workflow = PreparesCartForPayPal.new(
        user: current_user,
        purchase_amount_cents: params[:purchase_amount_cents],
        expected_ticket_ids: params[:ticket_ids])
    workflow.run
    workflow
  end

  private def stripe_workflow
    @reference = Payment.generate_reference
    PreparesCartForStripeJob.perform_later(
        user: current_user,
        params: card_params,
        purchase_amount_cents: params[:purchase_amount_cents],
        expected_ticket_ids: params[:ticket_ids],
        payment_reference: @reference)
  end

  private def card_params
    params.permit(
        :credit_card_number, :expiration_month,
        :expiration_year, :cvc,
        :stripe_token).to_h.symbolize_keys
  end

end
