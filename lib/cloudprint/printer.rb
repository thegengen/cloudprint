module CloudPrint
  class Printer
    class << self
      def find(printer_id)
        CloudPrint.connection.post('/printer', :printer_id => printer_id)
      end
    end
  end
end