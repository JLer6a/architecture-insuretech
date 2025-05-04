#!/bin/bash
echo "Тестирование Rate Limit:"
for i in {1..12}; do
  echo -n "[$i] "
  curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:8080/
done