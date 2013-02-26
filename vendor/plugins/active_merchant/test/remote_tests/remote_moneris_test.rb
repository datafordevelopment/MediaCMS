require File.dirname(__FILE__) + '/../test_helper'

class MonerisRemoteTest < Test::Unit::TestCase
  include ActiveMerchant::Billing
  
  def setup
    Base.gateway_mode = :test

    @gateway = MonerisGateway.new({
        :login => 'store1',
        :password => 'yesguy',
      })

    @creditcard = CreditCard.new({
      :number => '4242424242424242',
      :month => 8,
      :year => 2006,
      :first_name => 'Longbob',
      :last_name => 'Longsen'
    })
  end
  
  def test_remote_purchase
    order_id = generate_order_id
    assert response = @gateway.purchase(Money.ca_dollar(100), @creditcard, :order_id => order_id)
    assert_equal Response, response.class
    assert_equal     ["auth_code",
     "bank_totals",
     "card_type",
     "complete",
     "iso",
     "message",
     "receipt_id",
     "reference_num",
     "response_code",
     "ticket",
     "timed_out",
     "trans_amount",
     "trans_date",
     "trans_id",
     "trans_time",
     "trans_type"], response.params.keys.sort
    assert_match /APPROVED/, response.params['message']
    assert_equal 'Approved', response.message
    assert_equal true, response.params['complete']
    assert_equal true, response.success?
    assert_equal order_id, response.params['receipt_id']
    assert_equal "#{response.params['trans_id']};#{response.params['receipt_id']}", response.authorization
  end

  def test_authorization_and_capture
    order_id = generate_order_id
    response = @gateway.authorize(Money.ca_dollar(100), @creditcard, :order_id => order_id)
    assert response.success?
    assert response.authorization
    response = @gateway.capture(Money.ca_dollar(100), response.authorization)
    assert response.success?
  end
 
  # Void is currently not working 
  def test_authorization_and_void
    order_id = generate_order_id
    response = @gateway.authorize(Money.ca_dollar(100), @creditcard, :order_id => order_id)
    assert response.success?
    response = @gateway.void(response.authorization)
    assert response.success?
  end

  def test_remote_error
    order_id = generate_order_id
    assert response = @gateway.purchase(Money.ca_dollar(150), @creditcard, :order_id => order_id)
    assert_equal Response, response.class
    assert_equal ["auth_code",
     "bank_totals",
     "card_type",
     "complete",
     "iso",
     "message",
     "receipt_id",
     "reference_num",
     "response_code",
     "ticket",
     "timed_out",
     "trans_amount",
     "trans_date",
     "trans_id",
     "trans_time",
     "trans_type"], response.params.keys.sort
    assert_match /DECLINED/, response.params['message']
    assert_equal 'Declined', response.message
    assert_equal true, response.params['complete']
    assert_equal false, response.success?
  end

  private
  def generate_order_id
    "moneris_test_case" + rand(1000000).to_s
  end
end
