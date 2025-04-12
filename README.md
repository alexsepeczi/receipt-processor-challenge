# README

* Ruby version
3.3.6

# How to get this running

```bash
   git clone https://github.com/alexsepeczi/receipt-processor-challenge
```

```bash
   docker-compose build
```

```bash
  docker-compose up
```

And it should be ready to go!

# Example requests
Processing Receipts
```bash
   curl -X POST http://localhost:3000/receipts/process -H "Content-Type: application/json" -d '{"retailer":"Target","purchaseDate":"2022-01-01","purchaseTime":"13:01","items":[{"shortDescription":"Mountain Dew 12PK","price":"6.49"},{"shortDescription":"Emils Cheese Pizza","price":"12.25"},{"shortDescription":"Knorr Creamy Chicken","price":"1.26"},{"shortDescription":"Doritos Nacho Cheese","price":"3.35"},{"shortDescription":"   Klarbrunn 12-PK 12 FL OZ  ","price":"12.00"}],"total":"35.35"}'
```

Getting Points
```bash
  curl -X GET http://localhost:3000/receipts/27ae0f67-0875-48c7-a501-280965718602/points -H "Content-Type: application/json"
```


# How to run the test suite

```bash  
   rspec spec/requests/receipts_spec.rb 
```


