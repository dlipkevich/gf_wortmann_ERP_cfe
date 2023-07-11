﻿
&НаКлиенте
Процедура СписокСтатусовПриИзменении(Элемент)
	
	Если Отчет.СписокСтатусов.Количество() > 0 Тогда 
		ОтборПоСтатусам = Истина;
	иначе
		ОтборПоСтатусам = Ложь;
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ДоступныеТипы = Новый ОписаниеТипов("ПеречислениеСсылка.гф_СтатусыGTIN_В_НК");
	Отчет.СписокСтатусов.ТипЗначения = ДоступныеТипы;
	
	ДоступныеТипыВида = Новый ОписаниеТипов("СправочникСсылка.ВидыНоменклатуры");
	Отчет.ВидНоменклатуры.ТипЗначения = ДоступныеТипыВида;
	
КонецПроцедуры

&НаСервере
Процедура ПерезаполнитьТЧСписокДоступныхПоступлений()
	
	Если Отчет.ВидНоменклатуры.Количество() = 0 Тогда
		СписокВидов = Новый Массив;
		СписокВидов.Добавить(Справочники.ВидыНоменклатуры.НайтиПоНаименованию("Обувь"));
	Иначе 
		СписокВидов = Отчет.ВидНоменклатуры.ВыгрузитьЗначения();
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПриобретениеТоваровУслугТовары.Ссылка КАК Ссылка,
		|	ПриобретениеТоваровУслугТовары.Ссылка.Контрагент КАК Контрагент
		|ИЗ
		|	Документ.ПриобретениеТоваровУслуг.Товары КАК ПриобретениеТоваровУслугТовары
		|ГДЕ
		|	ПриобретениеТоваровУслугТовары.Номенклатура.ВидНоменклатуры В (&ВидНоменклатуры)
		|	И ПриобретениеТоваровУслугТовары.Ссылка.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания
		|	И ПриобретениеТоваровУслугТовары.Ссылка.Организация = &Организация";
	
	Запрос.УстановитьПараметр("ВидНоменклатуры", СписокВидов); 
	Запрос.УстановитьПараметр("ДатаНачала", Отчет.ПериодОтчета.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", Отчет.ПериодОтчета.ДатаОкончания); 
	Если ЗначениеЗаполнено(Отчет.Организация) Тогда
		 Запрос.УстановитьПараметр("Организация", Отчет.Организация);
	Иначе
		 Запрос.Текст = СтрЗаменить(Запрос.Текст, "И ПриобретениеТоваровУслугТовары.Ссылка.Организация = &Организация", "");
	КонецЕсли;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Отчет.СписокДоступныхПоступлений.Очистить();
	Пока Выборка.Следующий() Цикл
		  НоваяСтрока = Отчет.СписокДоступныхПоступлений.Добавить();
		  НоваяСтрока.Контрагент = Выборка.Контрагент;
		  НоваяСтрока.СсылкаНаДокумент = Выборка.Ссылка;
	КонецЦикла;
		
КонецПроцедуры

&НаКлиенте
Процедура Заполнить(Команда)
	
	Если Не ЗначениеЗаполнено(Отчет.ПериодОтчета) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не заполнен Период");
		Возврат;
	КонецЕсли;
	
	ПерезаполнитьТЧСписокДоступныхПоступлений();
КонецПроцедуры

&НаКлиенте
Процедура УстановитьМетки(Команда)  
		
	Если Команда = ЭтотОбъект.Команды.ОтметитьВсе Тогда
		
		Флаг = Истина;
		
	ИначеЕсли Команда = ЭтотОбъект.Команды.СнятьВсеОтметки Тогда
		
		Флаг = Ложь;
		
	Иначе       
		
		Возврат;
		
	КонецЕсли;			
	
	Для Каждого СтрокаТаблицы Из Отчет.СписокДоступныхПоступлений Цикл
		
		СтрокаТаблицы.Использовать = Флаг;
		
	КонецЦикла;	
	
КонецПроцедуры

