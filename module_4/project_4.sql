--Задание4.1
--БазаданныхсодержитсписокаэропортовпрактическивсехкрупныхгородовРоссии.Вбольшинствегородовестьтолькоодинаэропорт.Исключениесоставляет:
--------------------------
SELECTcity,count(distinctairport_code)ASairports_count
FROMdst_project.airports
GROUPBYcity
HAVINGcount(distinctairport_code)>1
ORDERBYairports_countDESC
--------------------------
--Ответ:Moscow,Ulyanovsk

--**************************************************
--Задание4.2
--Вопрос1.Таблицарейсовсодержитвсюинформациюопрошлых,текущихизапланированныхрейсах.Скольковсегостатусовдлярейсовопределеновтаблице?
--------------------------
SELECTcount(distinctstatus)
FROMdst_project.flights
--------------------------
--Ответ:6.

--Вопрос2.Какоеколичествосамолетовнаходятсяввоздухенамоментсрезавбазе(статусрейса«самолётужевылетелинаходитсяввоздухе»).
--------------------------
SELECTcount(distinctflight_id)
FROMdst_project.flights
WHEREstatus='Departed'
--------------------------
--Ответ:58

--Вопрос3.Местаопределяютсхемусалонакаждоймодели.Сколькоместимеетсамолетмодели(Boeing777-300)?
--------------------------
SELECTcount(distincts.seat_no)
FROMdst_project.aircraftsASa
JOINdst_project.seatsASs
ONa.aircraft_code=s.aircraft_code
WHEREa.modelLIKE'%Boeing%777-300%'
--------------------------
--Ответ:402

--Вопрос4.Сколькосостоявшихся(фактических)рейсовбылосовершеномежду1апреля2017годаи1сентября2017года?
--Здесьидалеесостоявшийсярейсозначает,чтооннеотменён,исамолётприбылвпунктназначения.
--------------------------
SELECTcount(flight_id)
FROMdst_project.flights
WHEREactual_arrivalBETWEEN'2017-04-01'AND'2017-09-02'
ANDstatus='Arrived'
--------------------------
--Ответ:74227

--**************************************************
--Задание4.3
--Вопрос1.Скольковсегорейсовбылоотмененоподаннымбазы?
--------------------------
SELECTcount(DISTINCTflight_id)
FROMdst_project.flights
WHEREstatus='Cancelled'
--------------------------
--Ответ:437

--Вопрос2.СколькосамолетовмоделейтипаBoeing,SukhoiSuperjet,Airbusнаходитсявбазеавиаперевозок?

--Boeing:
--------------------------
SELECTcount(distinctaircraft_code)
FROMdst_project.aircrafts
WHEREmodelLIKE'%Boeing%'
--------------------------
--Ответ:3

--SukhoiSuperjet:
--------------------------
SELECTcount(distinctaircraft_code)
FROMdst_project.aircrafts
WHEREmodelLIKE'%Sukhoi%Superjet%'
--------------------------
--Ответ:1

--Airbus:
--------------------------
SELECTcount(distinctaircraft_code)
FROMdst_project.aircrafts
WHEREmodelLIKE'%Airbus%'
--------------------------
--Ответ:3

--Вопрос3.Вкакойчасти(частях)светанаходитсябольшеаэропортов?
--------------------------
SELECT'Asia'ASzone,count(distinctairport_code)AStimezone_count
FROMdst_project.airports
WHEREtimezoneLIKE'%Asia%'

UNIONALL

SELECT'Europe'ASzone,count(distinctairport_code)AStimezone_count
FROMdst_project.airports
WHEREtimezoneLIKE'%Europe%'

UNIONALL

SELECT'Australia'ASzone,count(distinctairport_code)AStimezone_count
FROMdst_project.airports
WHEREtimezoneLIKE'%Australia%'
--------------------------
--Ответ:Europe,Asia

--Вопрос4.Укакогорейсабыласамаябольшаязадержкаприбытиязавсевремясбораданных?Введитеidрейса(flight_id).
--------------------------
SELECTflight_id,date_part('hour',actual_arrival-scheduled_arrival)asdelta_in_hour
FROMdst_project.flights
WHEREstatus='Arrived'
ORDERBYdelta_in_hourDESC
limit1
--------------------------
--Ответ:157571

--**************************************************
--Задание4.4
--Вопрос1.Когдабылзапланировансамыйпервыйвылет,сохраненныйвбазеданных?
--------------------------
SELECTscheduled_departure
FROMdst_project.flights
ORDERBYscheduled_departure
--------------------------
--Ответ:14.08.2016

--Вопрос2.Сколькоминутсоставляетзапланированноевремяполетавсамомдлительномрейсе?
--------------------------
SELECTflight_id,
date_part('hour',scheduled_arrival-scheduled_departure)*60
+date_part('minute',scheduled_arrival-scheduled_departure)ASdelta_date
FROMdst_project.flights
WHEREstatus='Arrived'
ORDERBYdelta_dateDESC
--------------------------
--Ответ:530

--Вопрос3.Междукакимиаэропортамипролегаетсамыйдлительныйповременизапланированныйрейс?
--------------------------
SELECTDISTINCTdeparture_airport,arrival_airport,date_part('hour',scheduled_arrival-scheduled_departure)*60+date_part('minute',scheduled_arrival-scheduled_departure)asdelta_date
FROMdst_project.flights
WHEREstatus='Arrived'
ORDERBYdelta_dateDESC
--------------------------
--Ответ:DME-UUS

--Вопрос4.Сколькосоставляетсредняядальностьполетасредивсехсамолетоввминутах?Секундыокругляютсявменьшуюсторону(отбрасываютсядоминут).
--------------------------
SELECTdate_part('hour',avg(actual_arrival-actual_departure))*60+date_part('minute',avg(actual_arrival-actual_departure))
FROMdst_project.flights
WHEREstatus='Arrived'
--------------------------
--Ответ:128


--**************************************************
--Задание4.5
--Вопрос1.МесткакогоклассауSU9большевсего?
--------------------------
SELECTs.fare_conditions,
count(DISTINCTseat_no)
FROMdst_project.aircraftsASa
JOINdst_project.seatsASsONa.aircraft_code=s.aircraft_code
WHEREa.aircraft_code='SU9'
GROUPBYs.fare_conditions
--------------------------
--Ответ:Economy.

--Вопрос2.Какуюсамуюминимальнуюстоимостьсоставилобронированиезавсюисторию?
--------------------------
SELECTmin(total_amount)
FROMdst_project.bookings
--------------------------
--Ответ:3400.

--Вопрос3.Какойномерместабылупассажирасid=4313788533?
--------------------------
SELECTpassenger_id,seat_no
FROMdst_project.ticketsASt
JOINdst_project.ticket_flightsAStf
ONtf.ticket_no=t.ticket_no
JOINdst_project.boarding_passesASbp
ONtf.ticket_no=bp.ticket_no
ANDtf.flight_id=bp.flight_id
WHEREt.passenger_id='4313788533'
--------------------------
--Ответ:2A.

--**************************************************
--Задание5.1

--Вопрос1.Анапа—курортныйгороднаюгеРоссии.СколькорейсовприбыловАнапуза2017год?
--------------------------
SELECTcount(f.flight_id)
FROMdst_project.flightsASf
JOINdst_project.airportsASaONa.airport_code=f.arrival_airport
WHEREa.city='Anapa'
AND(f.actual_arrivalBETWEEN'2017-01-01'AND'2018-01-01')
--------------------------
--Ответ:486рейсов.

--Вопрос2.СколькорейсовизАнапывылетелозимой2017года?
--------------------------
SELECTcount(flight_id)
FROMdst_project.flightsASf
JOINdst_project.airportsASaONa.airport_code=f.departure_airport
WHEREa.city='Anapa'
AND((f.actual_departureBETWEEN'2017-01-01'AND'2017-03-01')
OR(f.actual_departureBETWEEN'2017-12-01'AND'2017-12-31'))
ANDf.status!='Cancelled'
--------------------------
--Ответ:127рейсов.

--Вопрос3.ПосчитайтеколичествоотмененныхрейсовизАнапызавсевремя.
--------------------------
SELECTcount(flight_id)
FROMdst_project.flightsASf
JOINdst_project.airportsASaONa.airport_code=f.departure_airport
WHEREa.city='Anapa'
ANDf.status='Cancelled'
--------------------------
--Ответ:1рейс.

--Вопрос4.СколькорейсовизАнапынелетаютвМоскву?
--------------------------
SELECTcount(flight_id)
FROMdst_project.flightsASf
JOINdst_project.airportsASa1ONa1.airport_code=f.departure_airport
JOINdst_project.airportsASa2ONa2.airport_code=f.arrival_airport
WHEREa1.city='Anapa'
ANDa2.city!='Moscow'
--------------------------
--Ответ:453рейсов.

--Вопрос5.КакаямодельсамолеталетящегонарейсахизАнапыимеетбольшевсегомест?
--------------------------
SELECTac.model,count(distincts.seat_no)
FROMdst_project.flightsASf
JOINdst_project.airportsASa1ONa1.airport_code=f.departure_airport
JOINdst_project.aircraftsASacONac.aircraft_code=f.aircraft_code
JOINdst_project.seatsASsONac.aircraft_code=s.aircraft_code
WHEREa1.city='Anapa'
GROUPBYac.model
LIMIT1
--------------------------
--Ответ:Boeing737-300.
--------------------------


--ДОПОЛНИТЕЛЬНЫЕЗАПРОСЫ
--Вопрос:каковасредняя,максимальноеиминимальноезначениеотклоненияреальнойдлительностирейсаотзапланированой?
--------------------------
selectavg((scheduled_arrival-scheduled_departure)-(actual_arrival-actual_departure)),max((scheduled_arrival-scheduled_departure)-(actual_arrival-actual_departure)),min((scheduled_arrival-scheduled_departure)-(actual_arrival-actual_departure))fromdst_project.flights
--------------------------
--Ответ:среднее-0 минут,максимальное-22 минуты,минимальное-21 минута.
--------------------------


select
date_part('day',f.scheduled_departure-b.book_date),
f.scheduled_departure,
tf.amount
fromdst_project.flightsf
joindst_project.ticket_flightsAStfONf.flight_id=tf.flight_id
joindst_project.ticketsastont.ticket_no=tf.ticket_no
joindst_project.bookingsasbont.book_ref=b.book_ref
wheref.flight_id='136605'andtf.fare_conditions='Economy'
orderbyb.book_date

