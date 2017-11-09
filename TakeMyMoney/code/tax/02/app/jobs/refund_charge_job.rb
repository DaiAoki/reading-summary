#---
# Excerpted from "Take My Money",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/nrwebpay for more book information.
#---
class RefundChargeJob < ActiveJob::Base

  include Rollbar::ActiveJob

  queue_as :default

  def perform(refundable_id:)
    refundable = Payment.find(refundable_id)
    workflow = CreatesStripeRefund(refundable)
    workflow.run
  end

end
