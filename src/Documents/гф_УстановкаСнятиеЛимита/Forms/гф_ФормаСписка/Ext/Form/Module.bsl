﻿#Область ОбработчикиСобытийФормы   
// #wortmann { 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
// Параметры:
// Отказ, СтандартнаяОбработка 
&НаСервере 
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("Партнер") Тогда
		Партнер = Параметры.Партнер;		
		УстановитьОтборПоПартнеру();
	КонецЕсли; 
	
	Если РольДоступна("гф_ЧтениеУстановкаСнятиеЛимита") или  РольДоступна("гф_ЧтениеОтчетовПоДебетМенедженту") Тогда 
		Элементы.ЛимитГруппаСоздать.Видимость=Ложь;
	КонецЕсли;
	
КонецПроцедуры
// } #wortmann 

#КонецОбласти

#Область ОбработчикиСобытийЭлементовСтраницыФормыОсновная 
// #wortmann {
// Замена запроса для динамического списка
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаСервере
Процедура ИсторияНаСервере()
	Список.ТекстЗапроса = ЗаменитьТекстЗапросаВДинамическомСписке();
КонецПроцедуры
// } #wortmann 

// #wortmann {
// Отбор формы списка по партеру,для команды
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаСервере
Процедура УстановитьОтборПоПартнеру()

ЭлементОтбора = Список.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
ЭлементОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Партнер");
ЭлементОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
ЭлементОтбора.ПравоеЗначение =Партнер;		

КонецПроцедуры
// } #wortmann

// #wortmann { 
// Параметры:
//Команда 
// Обработка команды по созданию документа с видом операции установка лимита
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаКлиенте
Процедура СоздатьСнятиеЛимита(Команда) 
	
	ОперацияУстановкаЛимита = ПредопределенноеЗначение("Перечисление.гф_ВидыОперацийЛимита.СнятиеЛимита");
	ЭлементыОтбора = Новый Структура("ВидОперации", ОперацияУстановкаЛимита );
	ПараметрыФормы = Новый Структура("ЗначенияЗаполнения", ЭлементыОтбора);
	ОткрытьФорму("Документ.гф_УстановкаСнятиеЛимита.Форма.гф_ФормаДокумента", ПараметрыФормы, ЭтотОбъект); 
	
КонецПроцедуры
// } #wortmann

 // #wortmann {
 // Параметры:
// Команда 
// Обработка команды по созданию документа с видом операции снятие лимита
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаКлиенте
Процедура СоздатьУстановкаЛимита(Команда)
	
	ОперацияУстановкаЛимита = ПредопределенноеЗначение("Перечисление.гф_ВидыОперацийЛимита.УстановкаЛимита");
	ЭлементыОтбора = Новый Структура("ВидОперации", ОперацияУстановкаЛимита );
	ПараметрыФормы = Новый Структура("ЗначенияЗаполнения", ЭлементыОтбора);
	ОткрытьФорму("Документ.гф_УстановкаСнятиеЛимита.Форма.гф_ФормаДокумента", ПараметрыФормы, ЭтотОбъект); 
	
КонецПроцедуры
// } #wortmann

// #wortmann {
// Параметры:
// Команда 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05
&НаКлиенте
Процедура История(Команда)
	ИсторияНаСервере();
КонецПроцедуры
// } #wortmann

// #wortmann {
// Замена запроса для динамического списка
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/05  
// Возвращаемое значение:
// Запрос.Текс - текст запроса
&НаСервере
Функция ЗаменитьТекстЗапросаВДинамическомСписке() 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	гф_УстановкаСнятиеЛимита.Ссылка КАК Ссылка,
		|	гф_УстановкаСнятиеЛимита.Номер КАК Номер,
		|	гф_УстановкаСнятиеЛимита.Дата КАК Дата,
		|	гф_УстановкаСнятиеЛимита.Проведен КАК Проведен,
		|	гф_УстановкаСнятиеЛимита.ВидОперации КАК ВидОперации,
		|	гф_УстановкаСнятиеЛимита.Статус КАК Статус,
		|	гф_УстановкаСнятиеЛимита.Контрагент КАК Контрагент,
		|	гф_УстановкаСнятиеЛимита.Партнер КАК Партнер,
		|	гф_УстановкаСнятиеЛимита.Организация КАК Организация,
		|	гф_УстановкаСнятиеЛимита.ВидЛимита КАК ВидЛимита,
		|	гф_УстановкаСнятиеЛимита.Сумма КАК Сумма,
		|	гф_УстановкаСнятиеЛимита.Комментарий КАК Комментарий,
		|	гф_УстановкаСнятиеЛимита.Ответственный КАК Ответственный
		|ИЗ
		|	Документ.гф_УстановкаСнятиеЛимита КАК гф_УстановкаСнятиеЛимита";
	
	Возврат Запрос.Текст;
	
КонецФункции
// } #wortmann

// #wortmann {
// Параметры:
// Команда 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/14
&НаСервере
Процедура ОтключитьИсториюНаСервере()
	Список.ТекстЗапроса= ВернутьТекстЗапросаВДинамическомСписке();
КонецПроцедуры
// } #wortmann

// #wortmann {
// Параметры:
// Команда 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/14
&НаКлиенте
Процедура ОтключитьИсторию(Команда)
	ОтключитьИсториюНаСервере();
КонецПроцедуры 
// } #wortmann

// #wortmann {
// Параметры:
// Команда 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/09/14
&НаСервере
Функция ВернутьТекстЗапросаВДинамическомСписке() 
	Запрос = Новый Запрос;
	Запрос.Текст = 
 "ВЫБРАТЬ РАЗЛИЧНЫЕ
 |	гф_УстановкаСнятиеЛимита.Ссылка КАК Ссылка,
 |	гф_УстановкаСнятиеЛимита.Номер КАК Номер,
 |	гф_УстановкаСнятиеЛимита.Дата КАК Дата,
 |	гф_УстановкаСнятиеЛимита.ВидОперации КАК ВидОперации,
 |	гф_УстановкаСнятиеЛимита.Статус КАК Статус,
 |	гф_УстановкаСнятиеЛимита.Контрагент КАК Контрагент,
 |	гф_УстановкаСнятиеЛимита.Партнер КАК Партнер,
 |	гф_УстановкаСнятиеЛимита.Организация КАК Организация,
 |	гф_УстановкаСнятиеЛимита.ВидЛимита КАК ВидЛимита,
 |	гф_УстановкаСнятиеЛимита.Сумма КАК Сумма,
 |	ВЫРАЗИТЬ(гф_УстановкаСнятиеЛимита.Комментарий КАК СТРОКА(512)) КАК Комментарий,
 |	гф_УстановкаСнятиеЛимита.Ответственный КАК Ответственный
 |ИЗ
 |	(ВЫБРАТЬ
 |		МАКСИМУМ(гф_УстановкаСнятиеЛимита.Дата) КАК Дата,
 |		гф_УстановкаСнятиеЛимита.Контрагент КАК Контрагент,
 |		гф_УстановкаСнятиеЛимита.Организация КАК Организация,
 |		гф_УстановкаСнятиеЛимита.ВидЛимита КАК ВидЛимита
 |	ИЗ
 |		Документ.гф_УстановкаСнятиеЛимита КАК гф_УстановкаСнятиеЛимита
 |	
 |	СГРУППИРОВАТЬ ПО
 |		гф_УстановкаСнятиеЛимита.Контрагент,
 |		гф_УстановкаСнятиеЛимита.Организация,
 |		гф_УстановкаСнятиеЛимита.ВидЛимита) КАК ВложенныйЗапрос
 |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.гф_УстановкаСнятиеЛимита КАК гф_УстановкаСнятиеЛимита
 |		ПО ВложенныйЗапрос.Дата = гф_УстановкаСнятиеЛимита.Дата"  ;     
 	Возврат Запрос.Текст;
КонецФункции
// } #wortmann

#КонецОбласти