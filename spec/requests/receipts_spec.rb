require 'swagger_helper'

# Using rswag testing framework we can make these api specs quite easily and readable. It will create the actual
# responses in the background and test response codes.
RSpec.describe 'receipts', type: :request do
  # This group of tests will ensure both creation and retrieval of receipts works correctly
  path '/receipts/process' do
    post 'Submits a receipt for processing.' do
      consumes 'application/json'
      produces 'application/json'
      parameter name: :receipt, in: :body

      response(200, 'successful') do
        describe 'when all attributes are nil' do
          let(:receipt) { {} }
          run_test! do
            get "/receipts/#{response.parsed_body['id']}/points"

            expect(response.parsed_body['points']).to eq 0
          end
        end

        describe 'skips non-alphanumerics in retailer' do
          let(:receipt) { { retailer: '***' } }
          run_test! do
            get "/receipts/#{response.parsed_body['id']}/points"

            expect(response.parsed_body['points']).to eq 0
          end
        end

        # this will always get 25 for divisible by 0.25 as well
        describe '50 for round dollar' do
          let(:receipt) { { total: '10.00' } }
          run_test! do
            get "/receipts/#{response.parsed_body['id']}/points"

            expect(response.parsed_body['points']).to eq 75
          end
        end

        describe '25 for multiple of 0.25' do
          let(:receipt) { { total: '10.25' } }
          run_test! do
            get "/receipts/#{response.parsed_body['id']}/points"

            expect(response.parsed_body['points']).to eq 25
          end
        end

        describe '5 for every two on the receipt' do
          let(:receipt) { { items: [{}, {}, {}, {}, {}] } }
          run_test! do
            get "/receipts/#{response.parsed_body['id']}/points"

            expect(response.parsed_body['points']).to eq 10
          end
        end

        describe 'trimmed items descriptions' do
          let(:receipt) { { items: [{ shortDescription: '  asd   ', price: '101' }] } }

          run_test! do
            get "/receipts/#{response.parsed_body['id']}/points"

            expect(response.parsed_body['points']).to eq 21
          end
        end

        describe '6 for purchase day odd' do
          let(:receipt) { { purchaseDate: '2025-01-01' } }
          run_test! do
            get "/receipts/#{response.parsed_body['id']}/points"

            expect(response.parsed_body['points']).to eq 6
          end
        end

        describe '10 for purchase time inside 2 and 4' do
          let(:receipt) { { purchaseTime: '14:30' } }
          run_test! do
            get "/receipts/#{response.parsed_body['id']}/points"

            expect(response.parsed_body['points']).to eq 10
          end
        end

        describe '10 for purchase time inside 2 and 4 exclusive' do
          let(:receipt) { { purchaseTime: '14:00' } }
          run_test! do
            get "/receipts/#{response.parsed_body['id']}/points"

            expect(response.parsed_body['points']).to eq 0
          end
        end

        describe 'example_one' do
          let(:receipt) do
            {
              "retailer": 'Target',
              "purchaseDate": '2022-01-01',
              "purchaseTime": '13:01',
              "items": [
                {
                  "shortDescription": 'Mountain Dew 12PK',
                  "price": '6.49'
                }, {
                  "shortDescription": 'Emils Cheese Pizza',
                  "price": '12.25'
                }, {
                  "shortDescription": 'Knorr Creamy Chicken',
                  "price": '1.26'
                }, {
                  "shortDescription": 'Doritos Nacho Cheese',
                  "price": '3.35'
                }, {
                  "shortDescription": '   Klarbrunn 12-PK 12 FL OZ  ',
                  "price": '12.00'
                }
              ],
              "total": '35.35'
            }
          end
          run_test! do
            id = response.parsed_body['id']
            expect(id).to be_present
            expect(Rails.cache.read(id)).to be_present
            expect(Rails.cache.read(id).points).to eq 28
          end
        end

        describe 'example_two' do
          let(:receipt) do
            {
              "retailer": 'M&M Corner Market',
              "purchaseDate": '2022-03-20',
              "purchaseTime": '14:33',
              "items": [
                {
                  "shortDescription": 'Gatorade',
                  "price": '2.25'
                }, {
                  "shortDescription": 'Gatorade',
                  "price": '2.25'
                }, {
                  "shortDescription": 'Gatorade',
                  "price": '2.25'
                }, {
                  "shortDescription": 'Gatorade',
                  "price": '2.25'
                }
              ],
              "total": '9.00'
            }
          end
          run_test! do
            id = response.parsed_body['id']
            expect(id).to be_present
            expect(Rails.cache.read(id).points).to eq 109
          end
        end
      end

      response(400, 'bad request') do
        let(:receipt) { { purchaseDate: 'asdf' } }

        run_test! do
          expect(response.parsed_body['errors'].first['message']).to eq 'The receipt is invalid.'
        end
      end
    end
  end

  # This is simply to make sure the 404 error is handled correctly
  path '/receipts/{id}/points' do
    get 'Returns the points awarded for the receipt.' do
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path

      response(404, 'not found') do
        describe 'when all attributes are nil' do
          let(:id) { 'invalid' }
          run_test! do
            expect(response.parsed_body['errors'].first['message']).to eq 'No receipt found for that ID.'
          end
        end
      end
    end
  end
end
