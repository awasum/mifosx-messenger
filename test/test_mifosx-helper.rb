require 'test/unit'
require_relative File.dirname(__FILE__) + '/../lib/mifosx-messenger'

class TestMifosxHelper < Test::Unit::TestCase

  def setup
    mifos = MifosXHelper.new
  end
  
  def test_truth
    assert true
  end

  def test_client
    client = mifos.get_client(2, :fields => [ 'displayName', 'mobileNo' ] )
    puts "Client Name: " + client["displayName"] + ", Mobile: " + client["mobileNo"]
  end

  def test_get_loan
    loan = mifos.get_loan(4917, :fields => [ 'id', 'summary' ] )
    puts "Loan id: " + loan["id"].to_s + ", Outstanding: " + loan["summary"]["totalOutstanding"].to_s
  end

  def test_get_loan_transaction
    trans = mifos.get_loan_transaction(4917, 4252)
    puts "Loan transaction: #{trans["type"]["value"]} amount: #{trans["currency"]["code"]} #{trans["amount"].to_s}"
  end

  def test_get_savings
    savings = mifos.get_savings(214, :fields => [ 'id', 'summary' ] )
    puts "Savings id: " + savings["id"].to_s + ", Balance: " + savings["summary"]["accountBalance"].to_s
  end

  def test_get_savings_transaction
    trans = mifos.get_savings_transaction(214, 438165)
    puts "Savings transaction: #{trans["transactionType"]["value"]}, Amount: #{trans["currency"]["code"]} #{trans["amount"].to_s}. Balance: #{trans['runningBalance']}"
  end
end


