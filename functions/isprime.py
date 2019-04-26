def isprime(event,context):
  n= event['data']
  if n == 2 or n == 3: return "Prime"
  if n < 2 or n%2 == 0: return "Not Prime"
  if n < 9: return "Prime"
  if n%3 == 0: return "Not Prime"
  r = int(n**0.5)
  f = 5
  while f <= r:
    print '\t',f
    if n%f == 0: return "Not Prime"
    if n%(f+2) == 0: return "Not Prime"
    f +=6
  return "Prime"
