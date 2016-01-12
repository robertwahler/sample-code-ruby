require 'rubygems'
  require 'yaml'
  require 'authorizenet' 
 require 'securerandom'

  include AuthorizeNet::API

  def debit_bank_account()
    config = YAML.load_file(File.dirname(__FILE__) + "/../credentials.yml")
  
    transaction = Transaction.new(config['api_login_id'], config['api_transaction_key'], :gateway => :sandbox)
  
    request = CreateTransactionRequest.new
  
    request.transactionRequest = TransactionRequestType.new()
    request.transactionRequest.amount = SecureRandom.random_number.round(4)
    request.transactionRequest.payment = PaymentType.new
    request.transactionRequest.payment.bankAccount = BankAccountType.new(nil,'125000024','12345678', 'John Doe') 
    request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
    
    
    response = transaction.create_transaction(request)
  
    if response.messages.resultCode == MessageTypeEnum::Ok
      puts "Successfully made a purchase (Transaction ID: #{response.transactionResponse.transId})"
  
    else
      puts response.messages.messages[0].text
      puts response.transactionResponse.errors.errors[0].errorCode
      puts response.transactionResponse.errors.errors[0].errorText
      raise "Failed to make purchase."
    end
    
    return response
end
  
if __FILE__ == $0
  debit_bank_account()
end