#!/this/is/ignored

a = 1 + 2* 3 / 6

a, bunch, go, here = another, world

func arg1, arg2, another, arg3

here, we = () ->, yeah
the, different = () -> approach; yeah

dad()
dad(lord)
hello(one,two)()
(5 + 5)(world)

fun(a)(b)

fun(a) b

fun(a) b, bad hello

hello world what are you doing here


what(the)[3243] world, yeck heck

hairy[hands][are](gross) okay okay[world]

(get[something] + 5)[years]

i,x  = 200, 300

yeah = (1 + 5) * 3
yeah = ((1+5)*3)/2
yeah = ((1+5)*3)/2 + i % 100

whoa = (1+2) * (3+4) * (4+5)

->
  if something
    return 1,2,4

  print "hello"

->
  if hello
    "heloo", "world"
  else
    no, way


-> 1,2,34

return 5 + () -> 4 + 2

return 5 + (() -> 4) + 2

print 5 + () ->
	34
	good nads


something 'else', "ya"

something'else'
something"else"

something[[hey]] * 2
something[======[hey]======] * 2


something'else', 2
something"else", 2
something[[else]], 2

something 'else', 2
something "else", 2
something [[else]], 2

here(we)"go"[12123]

-- this runs
something =
  test: 12323
  what: -> print "hello world"

print something.test

frick = hello: "world"

argon =
  num: 100
  world: (self) ->
    print self.num
    return {
      something: -> print "hi from something"
    }
  somethin: (self, str) ->
    print "string is", str
    return world: (a,b) -> print "sum", a + b

something.what()
argon\world().something()

argon\somethin"200".world(1,2)

x = -434

x = -hello world one two

hi = -"herfef"

x = -[x for x in x]

print "hello" if cool
print "hello" unless cool
print "hello" unless 1212 and 3434 -- hello
print "hello" for i=1,10

print "nutjob"

if hello then 343

print "what" if cool else whack

arg = {...}

x = (...) ->
  dump {...}


x = not true

y = not(5+5)


y = #"hello"

x = #{#{},#{1},#{1,2}}

hello, world

something\hello(what) a,b
something\hello what
something.hello\world a,b
something.hello\world(1,2,3) a,b


x = 1232
x += 10 + 3
j -= "hello"
y *= 2
y /= 100
m %= 2
hello ..= "world"

@@something += 10
@something += 10

a["hello"] += 10
a["hello#{tostring ff}"] += 10
a[four].x += 10

x = 0
(if ntype(v) == "fndef" then x += 1) for v in *values


hello =
  something: world
  if: "hello"
  else: 3434
  function: "okay"
  good: 230203


div class: "cool"

5 + what wack
what whack + 5

5 - what wack
what whack - 5

x = hello - world - something

((something = with what
  \cool 100) ->
  print something)!

if something
  03589

-- okay what about this

else
  3434


if something
  yeah


elseif "ymmm"

  print "cool"

else

  okay


-- test names containing keywords
x = notsomething
y = ifsomething
z = x and b
z = x andb


-- undelimited tables

while 10 > something
  something: "world"
    print "yeah"

x =
  okay: sure

yeah
  okay: man
  sure: sir

hello "no comma"
 yeah: dada
 another: world

hello "comma",
 something: hello_world
 frick: you

-- creates two tables
another hello, one,
  two, three, four, yeah: man
  okay: yeah

-- 
a += 3 - 5
a *= 3 + 5
a *= 3
a >>= 3
a <<= 3
a /= func "cool"

---

x.then = "hello"
x.while.true = "hello"

--

x or= "hello"
x and= "hello"

--

z = a-b
z = a -b
z = a - b
z = a- b

--

a={}
c=a+[]b -- append a,b, keep a not changed
d=a-[]b -- remove value b
g=a|[n]b -- insert a,b
a%%[]b -- remove all b
a-[n] -- remove key n
e=a[]+c -- merge a,b
f=a[+]c -- map +,a,c
[x]a -- a[x]!
[x]a(...) -- a[x](...)
a<-$3,2,$5=4,p=21> -- (n1,n2,n3,n5=4,p=21,...)-> a(n1,n2,n3,2,n5,p,...)

f^v -- (do (repeat r=f(v);v=r if r;break unless r;);v)
t.^*f -- `f v for v in t
t.^*.t1 -- f v for v in t for f in t1
([[.^*].] t t1)
v^*.t -- f v for f in t
f*.f2*.t -- 
<~f1,f2,f3> -- ((...)->f1 f2 f3(...))

t^ipairs.^f -- f(x1,x2) for x1,x2 in ipairs(t)
t^ipairs.^f.^f2 -- f(x3,x4) for x3,x4 in f(x1,x2) for x1,x2 in ipairs(t)
[t^ipairs.^f].^f2
t^ipairs.^<~f,f2> -- {<...>f2(f(...))}(...) for ... in ipairs(t)
t^ipairs.^f2.^.(ft^ipairs) -- f(x3,x4) for x1,x2 in ipairs(t) for f in ipairs(ft) for x3,x4 in f(x1,x2)
t^ipairs.^.(tf^ipairs).^.(ft2^ipairs) -- f(x3,x4) for x1,x2 in ipairs(t) for f in ipairs(ft) for x3,x4 in f(x1,x2)

v^<f1^+f2> -- {<x>f1(x),f2(x)}(v)
f.^f2 -- {<x> f2(v,i) for i,v in f(x)}
foreach(t,f) -- f(v,i) for i,v in t

t^*<2>f -- f(v,i) for i,v in *t
t^*{<...>} -- ((v,i)->)(v,i) for v,i in *t
{<...>} -- ((...)->)
<f1^f2^f3~> -- (...)-> f1(f2(f3(...)))
<~f1^f2^f3> -- (...)-> f3(f2(f1(...)))
f<,$3=23,$4:w,lj> -- ((n1,n2,n3=23)-> f(n1,n2,n3,w,lj))
v^f -- f(v)
[x](kke)t -- t[x](kke)
[](kke)t -- (x)->t[x](kke)
[]t -- (x)->(...)->t[x](...)
[x]{
	a:wlkelk
	b:
		lkjefl
	else:
		lwkje
} -- switch x when ...
[x](kke){} -- (switch x when ...)(kke)

@<-thisco={
	<data,d>~>{
		<a,b>
		<le,wl>~> last_co
	}~>ctrlv,<sjk,kj> -- 
}

thisco=(data,d)->
	ctrlv,{sjk,kj}=coresume(cocreate((a,b)->
		coyield(last_co,le,wl)
	))
last_co=thisco
coresume(thisco)
	
sfew=<x>
-- cooool

{|print("lwkej")}
(1-2+3)

-- ParensExp
ef=(+--welkjf
1--wej
2 3
(233 + 23)
(- 23 324)
)

--]]

a^^[]b

~>	cowrap ->

#macro
#default params

//'a bf c d'// 'a','bf','c','d'
