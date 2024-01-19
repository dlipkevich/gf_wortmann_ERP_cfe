﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	РежимРаботы = 0;
	ОтборПоСписку = Ложь;
	
	СписокДоступныхКонтрагентов.Очистить();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ) 
	
	РежимРаботыПриИзменении(Элементы.РежимРаботы);
	ОтборПоСпискуПриИзменении(Элементы.ОтборПоСписку);
	
КонецПроцедуры

&НаКлиенте
Процедура РежимРаботыПриИзменении(Элемент)
	
	Если РежимРаботы = 0 Тогда 
		Элементы.СтраницаНаАванс.Видимость = Истина;
		Элементы.СтраницаНаПоставку.Видимость = Ложь;
	Иначе
		Элементы.СтраницаНаАванс.Видимость = Ложь;
		Элементы.СтраницаНаПоставку.Видимость = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьФлажки(Команда)
	
	Если РежимРаботы = 0 Тогда
		Для Каждого Элемент Из ТаблицаСпецификацийАванса Цикл
			Элемент.Пометка = Истина;
		КонецЦикла;
	Иначе
		Для Каждого Элемент Из ТаблицаСпецификацийПоставки Цикл
			Элемент.Пометка = Истина;
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СнятьФлажки(Команда)  
	
	Если РежимРаботы = 0 Тогда
		Для Каждого Элемент Из ТаблицаСпецификацийАванса Цикл
			Элемент.Пометка = Ложь;
		КонецЦикла;
	Иначе
		Для Каждого Элемент Из ТаблицаСпецификацийПоставки Цикл
			Элемент.Пометка = Ложь;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

#Область ЗаполнениеТаблицИСозданиеСчетов

&НаКлиенте
Процедура Заполнить(Команда)
	
	ТаблицаСпецификацийАванса.Очистить();
	ТаблицаСпецификацийПоставки.Очистить();
	
	Если РежимРаботы = 0 Тогда
		
		Если ДатаНачала = Дата(1,1,1) Или ДатаОкончания = Дата(1,1,1) Тогда
			Сообщить("Выберите период заполнения!");
			Возврат;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(Сезон) Тогда
			Сообщить("Выберите не пустой сезон!");
			Возврат;
		КонецЕсли;

		ЗаполнитьНаАвансНаСервере(); 
		
	ИначеЕсли РежимРаботы = 1 Тогда 
		
		ЗаполнитьНаПоставкуНаСервере(); 
		
	КонецЕсли; 
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаАвансНаСервере()

	ТаблицаСпецификацийАванса.Очистить();;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	гф_СпецификацияПокупателя.Ссылка КАК Ссылка,
	|	гф_СпецификацияПокупателя.Контрагент КАК Контрагент,
	|	гф_СпецификацияПокупателя.Организация КАК Организация,
	|	гф_СпецификацияПокупателя.Договор КАК Договор,
	|	СУММА(гф_СпецификацияПокупателяЗаказыКлиентов.ЗаказКлиента.СуммаДокумента) КАК Сумма
	|ПОМЕСТИТЬ втСпецификации
	|ИЗ
	|	Документ.гф_СпецификацияПокупателя КАК гф_СпецификацияПокупателя
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.гф_СпецификацияПокупателя.ЗаказыКлиентов КАК гф_СпецификацияПокупателяЗаказыКлиентов
	|		ПО (гф_СпецификацияПокупателя.Ссылка = гф_СпецификацияПокупателяЗаказыКлиентов.Ссылка)
	|ГДЕ
	|	гф_СпецификацияПокупателя.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И гф_СпецификацияПокупателя.Договор.гф_Сезон = &Сезон
	|	И гф_СпецификацияПокупателя.Проведен
	|
	|СГРУППИРОВАТЬ ПО
	|	гф_СпецификацияПокупателя.Ссылка,
	|	гф_СпецификацияПокупателя.Контрагент,
	|	гф_СпецификацияПокупателя.Организация,
	|	гф_СпецификацияПокупателя.Договор
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Ссылка,
	|	Договор
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	втСпецификации.Договор КАК Договор,
	|	ДополнительныеРеквизитыСтраховойДепозит.Значение КАК СтраховойДепозит,
	|	ДополнительныеРеквизитыПредоплата.Значение КАК Предоплата
	|ПОМЕСТИТЬ втСвойстваДоговора
	|ИЗ
	|	втСпецификации КАК втСпецификации
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов.ДополнительныеРеквизиты КАК ДополнительныеРеквизитыСтраховойДепозит
	|		ПО втСпецификации.Договор = ДополнительныеРеквизитыСтраховойДепозит.Ссылка
	|			И (ДополнительныеРеквизитыСтраховойДепозит.Свойство = &СвойствоСтраховойДепозит)
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов.ДополнительныеРеквизиты КАК ДополнительныеРеквизитыПредоплата
	|		ПО втСпецификации.Договор = ДополнительныеРеквизитыПредоплата.Ссылка
	|			И (ДополнительныеРеквизитыПредоплата.Свойство = &СвойствоПредоплата)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втСвойстваДоговора.Договор КАК Договор
	|ПОМЕСТИТЬ втОтобранныеДоговора
	|ИЗ
	|	втСвойстваДоговора КАК втСвойстваДоговора
	|ГДЕ
	|	(ЕСТЬNULL(втСвойстваДоговора.СтраховойДепозит, ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяССылка)) <> ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяССылка)
	|			ИЛИ ЕСТЬNULL(втСвойстваДоговора.Предоплата, ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяССылка)) <> ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяССылка))
	|
	|СГРУППИРОВАТЬ ПО
	|	втСвойстваДоговора.Договор
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Договор
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ИСТИНА КАК Пометка,
	|	втСпецификации.Ссылка КАК Спецификация,
	|	втСпецификации.Контрагент КАК Контрагент,
	|	втСпецификации.Организация КАК Организация,
	|	втСпецификации.Договор КАК Договор,
	|	втСпецификации.Сумма КАК Сумма,
	|	втСвойстваДоговора.СтраховойДепозит КАК УслугаДепозита,
	|	втСвойстваДоговора.Предоплата КАК УслугаПредоплаты,
	|	гф_ПроцентыПредоплатыПоДепозиту.Процент КАК Депозит,
	|	гф_ПроцентыПредоплатыСкидкаЗаПредоплату.Процент КАК Предоплата
	|ИЗ
	|	втСпецификации КАК втСпецификации
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ втОтобранныеДоговора КАК втОтобранныеДоговора
	|			ЛЕВОЕ СОЕДИНЕНИЕ втСвойстваДоговора КАК втСвойстваДоговора
	|				ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.гф_ПроцентыПредоплаты КАК гф_ПроцентыПредоплатыПоДепозиту
	|				ПО (втСвойстваДоговора.СтраховойДепозит = гф_ПроцентыПредоплатыПоДепозиту.Номеклатура)
	|				ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.гф_ПроцентыПредоплаты КАК гф_ПроцентыПредоплатыСкидкаЗаПредоплату
	|				ПО (втСвойстваДоговора.Предоплата = гф_ПроцентыПредоплатыСкидкаЗаПредоплату.Номеклатура)
	|			ПО (втОтобранныеДоговора.Договор = втСвойстваДоговора.Договор)
	|		ПО (втСпецификации.Договор = втОтобранныеДоговора.Договор)
	|
	|СГРУППИРОВАТЬ ПО
	|	втСпецификации.Ссылка,
	|	втСпецификации.Контрагент,
	|	втСпецификации.Организация,
	|	втСпецификации.Договор,
	|	втСвойстваДоговора.СтраховойДепозит,
	|	втСвойстваДоговора.Предоплата,
	|	гф_ПроцентыПредоплатыПоДепозиту.Процент,
	|	гф_ПроцентыПредоплатыСкидкаЗаПредоплату.Процент,
	|	втСпецификации.Сумма";
	
	Запрос.УстановитьПараметр("Сезон", Сезон);
	Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", ДатаОкончания);  
	Запрос.УстановитьПараметр("СвойствоСтраховойДепозит", ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "гф_ДоговорыКонтрагентовСтраховойДепозит"));  
	Запрос.УстановитьПараметр("СвойствоПредоплата", ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "гф_ДоговорыКонтрагентовПредоплата"));  

	ТзЗапроса = Запрос.Выполнить().Выгрузить();  
	
	Если ТзЗапроса.Количество() = 0 Тогда
		Сообщить("Нет данных для заполнения!");
	КонецЕсли;
	
	ТаблицаСпецификацийАванса.Загрузить(ТзЗапроса); 

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаПоставкуНаСервере()

	ТаблицаСпецификацийПоставки.Очистить();   
	
	Если ОтборПоСписку И СписокВыбранныхКонтрагентов.Количество() > 0 Тогда  
		КонтрагентДляЗапроса = СписокВыбранныхКонтрагентов;
	ИначеЕсли ЗначениеЗаполнено(КонтрагентПоставки) Тогда
		КонтрагентДляЗапроса = КонтрагентПоставки;		
	КонецЕсли;

	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ТзЗапроса = ОбработкаОбъект.ЗаполнитьТаблицуДляВыставленияСчетовНаПоставку(ДатаНачалаПоставки, ДатаОкончанияПоставки, НомерПоставки, КонтрагентДляЗапроса, СезонПоставки);
	ТаблицаСпецификацийПоставки.Загрузить(ТзЗапроса); 

КонецПроцедуры

&НаКлиенте
Процедура Сформировать(Команда)
	
	СтрокаОшибок = "";
	
	Если РежимРаботы = 0 Тогда		
		СтрокаОшибок = СформироватьНаАвансНаСервере();		
	ИначеЕсли РежимРаботы = 1 Тогда
		СтрокаОшибок = СформироватьНаПоставкуНаСервере();		
	КонецЕсли;  
	
	Если Не ПустаяСтрока(СтрокаОшибок) Тогда
		Сообщить(СтрокаОшибок);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция СформироватьНаАвансНаСервере() 
	
	СтрокиДляФормирования = ТаблицаСпецификацийАванса.НайтиСтроки(Новый Структура("Пометка", Истина));
	
	Если СтрокиДляФормирования.Количество() = 0 Тогда
		Возврат "Нет данных для формирования счетов!";
	КонецЕсли;
	
	ТекущийПользователь = ПараметрыСеанса.ТекущийПользователь;  
	СтрокаСообщений = "";
	
	Для Каждого Элемент Из СтрокиДляФормирования Цикл 
		
		Если ЗначениеЗаполнено(Элемент.УслугаДепозита) Тогда 
			
			СчетСсылка = НайтиСчетНаОплатуПоСпецификации(Элемент.Спецификация, Элемент.УслугаДепозита);
			
			Если СчетСсылка = Неопределено Тогда
				ДокументСчет = Документы.СчетНаОплатуКлиенту.СоздатьДокумент();
			Иначе
				ДокументСчет = СчетСсылка.ПолучитьОбъект();
			КонецЕсли;
			
			ДокументСчет.Дата = ТекущаяДата();
			ДокументСчет.Организация = Элемент.Организация;
			ДокументСчет.СуммаДокумента = Элемент.Сумма * Элемент.Депозит / 100;
			
			ДоговорКонтрагента = Элемент.Договор;
			ДокументСчет.Валюта = ДоговорКонтрагента.ВалютаВзаиморасчетов;
			ДокументСчет.БанковскийСчет = ДоговорКонтрагента.БанковскийСчет;
			ДокументСчет.Договор = ДоговорКонтрагента; 
			ДокументСчет.ДокументОснование = ДоговорКонтрагента;
			ДокументСчет.ЧастичнаяОплата = Истина;     
			
			ДокументСчет.НазначениеПлатежа = Элемент.УслугаДепозита.Наименование + " " + ДоговорКонтрагента;
			ДокументСчет.Контрагент = Элемент.Контрагент; 
			ДокументСчет.Партнер = Элемент.Контрагент.Партнер; 
			
			ДокументСчет.гф_СпецификацияПокупателя = Элемент.Спецификация;
			ДокументСчет.Автор = ТекущийПользователь;
			// ++ Галфинд СадомцевСА 17.01.2024 Реализовал заполнение Банковского счета в Счете на оплату клиенту из обработки
			// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eeb44517bd9ea7
			Если ЗначениеЗаполнено(БанковскийСчет) Тогда
				ДокументСчет.БанковскийСчет = БанковскийСчет;
			КонецЕсли;
			// -- Галфинд СадомцевСА 17.01.2024
			
			ДокументСчет.ЭтапыГрафикаОплаты.Очистить();
			
			СтрокаПлатежа = ДокументСчет.ЭтапыГрафикаОплаты.Добавить();
			СтрокаПлатежа.ДатаПлатежа = ДокументСчет.Дата;
			СтрокаПлатежа.ПроцентПлатежа = 100;
			СтрокаПлатежа.СуммаПлатежа = Элемент.Сумма * Элемент.Депозит / 100;
			
			Попытка
				ДокументСчет.Записать(РежимЗаписиДокумента.Проведение);
				СтрокаСообщений = СтрокаСообщений + "Записан счет: " + ДокументСчет.Ссылка + Символы.ПС;
			Исключение
				ОписаниеОшибки = ОписаниеОшибки();
				СтрокаСообщений = СтрокаСообщений + "Ошибка при записи счета для документа: " + Элемент.Спецификация + " - " + ОписаниеОшибки + Символы.ПС;
			КонецПопытки;
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Элемент.УслугаПредоплаты) Тогда 
			
			СчетСсылка = НайтиСчетНаОплатуПоСпецификации(Элемент.Спецификация, Элемент.УслугаПредоплаты);
			
			Если СчетСсылка = Неопределено Тогда
				ДокументСчет = Документы.СчетНаОплатуКлиенту.СоздатьДокумент();
			Иначе
				ДокументСчет = СчетСсылка.ПолучитьОбъект();
			КонецЕсли;
			
			ДокументСчет.Дата = ТекущаяДата();
			ДокументСчет.Организация = Элемент.Организация;
			ДокументСчет.СуммаДокумента =  Элемент.Сумма * Элемент.Предоплата / 100;
			
			ДоговорКонтрагента = Элемент.Договор;
			ДокументСчет.Валюта = ДоговорКонтрагента.ВалютаВзаиморасчетов;
			ДокументСчет.БанковскийСчет = ДоговорКонтрагента.БанковскийСчет;
			ДокументСчет.Договор = ДоговорКонтрагента;  
			ДокументСчет.ДокументОснование = ДоговорКонтрагента; 
			ДокументСчет.ЧастичнаяОплата = Истина;
			
			ДокументСчет.НазначениеПлатежа = Элемент.УслугаПредоплаты.Наименование + " " + ДоговорКонтрагента;
			ДокументСчет.Контрагент = Элемент.Контрагент; 
			ДокументСчет.Партнер = Элемент.Контрагент.Партнер;   
			ДокументСчет.ЧастичнаяОплата = Истина; 
			
			ДокументСчет.гф_СпецификацияПокупателя = Элемент.Спецификация;
			ДокументСчет.Автор = ТекущийПользователь;
			// ++ Галфинд СадомцевСА 17.01.2024 Реализовал заполнение Банковского счета в Счете на оплату клиенту из обработки
			// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eeb44517bd9ea7
			Если ЗначениеЗаполнено(БанковскийСчет) Тогда
				ДокументСчет.БанковскийСчет = БанковскийСчет;
			КонецЕсли;
			// -- Галфинд СадомцевСА 17.01.2024
			
			ДокументСчет.ЭтапыГрафикаОплаты.Очистить();
			
			СтрокаПлатежа = ДокументСчет.ЭтапыГрафикаОплаты.Добавить();
			СтрокаПлатежа.ДатаПлатежа = ДокументСчет.Дата;
			СтрокаПлатежа.ПроцентПлатежа = 100;
			СтрокаПлатежа.СуммаПлатежа = Элемент.Сумма * Элемент.Предоплата / 100;
			
			Попытка
				ДокументСчет.Записать(РежимЗаписиДокумента.Проведение);  
				СтрокаСообщений = СтрокаСообщений + "Записан счет: " + ДокументСчет.Ссылка + Символы.ПС;
			Исключение
				ОписаниеОшибки = ОписаниеОшибки();
				СтрокаСообщений = СтрокаСообщений + "Ошибка при записи счета для документа: " + Элемент.Спецификация + " - " + ОписаниеОшибки + Символы.ПС;
			КонецПопытки;
			
		КонецЕсли;
		
	КонецЦикла;
	
    Возврат СтрокаСообщений;
	
КонецФункции

&НаСервере
Функция СформироватьНаПоставкуНаСервере() 
	
	ТаблицаДанных = ТаблицаСпецификацийПоставки.Выгрузить(Новый Структура("Пометка", Истина)); 
	Если ТаблицаДанных.Количество() = 0 Тогда
		Возврат "Нет данных для формирования счетов!";
	КонецЕсли;
	
	ТаблицаДанных.Колонки.Добавить("БанковскийСчет", Новый ОписаниеТипов("СправочникСсылка.БанковскиеСчетаОрганизаций"));
	
	Для Каждого СтрокаТаблицы Из ТаблицаДанных Цикл
		
		// ++ Галфинд СадомцевСА 17.01.2024 Реализовал заполнение Банковского счета в Счете на оплату клиенту из обработки
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eeb44517bd9ea7
		Если ЗначениеЗаполнено(БанковскийСчет) Тогда
			СтрокаТаблицы.БанковскийСчет = БанковскийСчет;
		Иначе
			СтрокаТаблицы.БанковскийСчет = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаТаблицы.Договор, "БанковскийСчет");
		КонецЕсли;
		
	КонецЦикла;
	
	ТаблицаДляСчетов = ТаблицаДанных.Скопировать();
	
	КолонкиГруппировок = "ПТУ, Организация, Контрагент, Договор, БанковскийСчет";
	ТаблицаДляСчетов.Свернуть(КолонкиГруппировок, "Сумма");
	
	СтуктураПоискаДанных = Новый Структура(КолонкиГруппировок);
	
	ТекущийПользователь = ПараметрыСеанса.ТекущийПользователь;  
	СтрокаСообщений = "";
	
	Для Каждого СтрокаСчетов Из ТаблицаДляСчетов Цикл 
			
		СчетСсылка = НайтиСчетНаОплатуПоПоставке(СтрокаСчетов.ПТУ, СтрокаСчетов.Контрагент, СтрокаСчетов.Договор);
		
		Если СчетСсылка = Неопределено Тогда
			ДокументСчет = Документы.СчетНаОплатуКлиенту.СоздатьДокумент();
		Иначе
			ДокументСчет = СчетСсылка.ПолучитьОбъект();
		КонецЕсли;
		
		ДокументСчет.Дата = ТекущаяДата();
		ДокументСчет.Организация = СтрокаСчетов.Организация;
		ДокументСчет.СуммаДокумента = СтрокаСчетов.Сумма;
		
		ДоговорКонтрагента = СтрокаСчетов.Договор;
		ДокументСчет.Валюта = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ДоговорКонтрагента, "ВалютаВзаиморасчетов");
		ДокументСчет.БанковскийСчет = СтрокаСчетов.БанковскийСчет;
		ДокументСчет.Договор = ДоговорКонтрагента; 
		ДокументСчет.ДокументОснование = ДоговорКонтрагента;
		//ДокументСчет.ЧастичнаяОплата = Истина;       
		
		ДокументСчет.Контрагент = СтрокаСчетов.Контрагент; 
		ДокументСчет.Партнер = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаСчетов.Контрагент, "Партнер"); 
		
		ДокументСчет.гф_НомерПоставки = СтрокаСчетов.ПТУ;
		ДокументСчет.Автор = ТекущийПользователь;
		
		// ЭтапыГрафикаОплаты
		ДокументСчет.ЭтапыГрафикаОплаты.Очистить();
		
		СтрокаПлатежа = ДокументСчет.ЭтапыГрафикаОплаты.Добавить();
		СтрокаПлатежа.ДатаПлатежа = ДокументСчет.Дата;
		СтрокаПлатежа.ПроцентПлатежа = 100;
		СтрокаПлатежа.СуммаПлатежа = ДокументСчет.СуммаДокумента;
		
		// гф_ТоварыВКоробах
		ДокументСчет.гф_ТоварыВКоробах.Очистить();
		
		ЗаполнитьЗначенияСвойств(СтуктураПоискаДанных, СтрокаСчетов);
		ТаблицаВариантов = ТаблицаДанных.Скопировать(СтуктураПоискаДанных,
			"ВариантКомплектации, Количество, Цена, Сумма");
		ДокументСчет.гф_ТоварыВКоробах.Загрузить(ТаблицаВариантов);
		
		// НазначениеПлатежа
		НазначенияПлатежа = Новый Массив;
		Для Каждого СтрокаВариантов Из ТаблицаВариантов Цикл
			НазначенияПлатежа.Добавить(СтрокаВариантов.ВариантКомплектации);
		КонецЦикла;
		ДокументСчет.НазначениеПлатежа = СтрСоединить(НазначенияПлатежа, ",");
				
		Попытка
			ДокументСчет.Записать(РежимЗаписиДокумента.Проведение);
			СтрокаСообщений = СтрокаСообщений + "Записан счет: " + ДокументСчет.Ссылка + Символы.ПС;
		Исключение
			ОписаниеОшибки = ОписаниеОшибки();
			СтрокаСообщений = СтрокаСообщений + "Ошибка при записи счета для документа: " + СтрокаСчетов.ПТУ + " - " + ОписаниеОшибки + Символы.ПС;
		КонецПопытки;
			
	КонецЦикла;
	
    Возврат СтрокаСообщений;
	
КонецФункции

&НаСервере
Функция НайтиСчетНаОплатуПоСпецификации(ДокументСпецификация, НазначениеПлатежа) 
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ Разрешенные
	|	СчетНаОплатуКлиенту.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.СчетНаОплатуКлиенту КАК СчетНаОплатуКлиенту
	|ГДЕ
	|	СчетНаОплатуКлиенту.гф_СпецификацияПокупателя = &СпецификацияСсылка
	|	И СчетНаОплатуКлиенту.НазначениеПлатежа Подобно &НазначениеПлатежа
	|	И Не СчетНаОплатуКлиенту.ПометкаУдаления";
	Запрос.УстановитьПараметр("СпецификацияСсылка", ДокументСпецификация);
	Запрос.УстановитьПараметр("НазначениеПлатежа", НазначениеПлатежа.Наименование + "%"); 
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		
		Возврат Неопределено;   
		
	Иначе 
		
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		
		Возврат Выборка.Ссылка; 
		
	КонецЕсли;
		
КонецФункции

&НаСервере
Функция НайтиСчетНаОплатуПоПоставке(ДокументПТУ, КонтрагентСчета, ДоговорСчета, НазначениеПлатежа = Неопределено) 
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ Разрешенные
	|	СчетНаОплатуКлиенту.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.СчетНаОплатуКлиенту КАК СчетНаОплатуКлиенту
	|ГДЕ
	|	СчетНаОплатуКлиенту.гф_НомерПоставки = &ДокументПТУ 
	|	И СчетНаОплатуКлиенту.Контрагент = &КонтрагентСчета
	|	И СчетНаОплатуКлиенту.Договор = &ДоговорСчета
	//|	И СчетНаОплатуКлиенту.НазначениеПлатежа Подобно &НазначениеПлатежа
	|	И Не СчетНаОплатуКлиенту.ПометкаУдаления";
	Запрос.УстановитьПараметр("ДокументПТУ", ДокументПТУ); 
	Запрос.УстановитьПараметр("КонтрагентСчета", КонтрагентСчета);
	Запрос.УстановитьПараметр("ДоговорСчета", ДоговорСчета);
	//Запрос.УстановитьПараметр("НазначениеПлатежа", НазначениеПлатежа.Наименование + "%"); 
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		
		Возврат Неопределено;   
		
	Иначе 
		
		Выборка = РезультатЗапроса.Выбрать();
		Выборка.Следующий();
		
		Возврат Выборка.Ссылка; 
		
	КонецЕсли;
		
КонецФункции

#КонецОбласти

&НаКлиенте
Процедура ПериодЗаполненияПриИзменении(Элемент)

	ДатаНачала = ПериодЗаполнения.ДатаНачала;
	ДатаОкончания = ПериодЗаполнения.ДатаОкончания;
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаСпецификацийВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если Поле.Имя = "Договор"	
		Или Поле.Имя = "Контрагент"
		Или Поле.Имя = "Спецификация"
		Или Поле.Имя = "УслугаДепозита"
		Или Поле.Имя = "УслугаПредоплаты" Тогда
		
		ПоказатьЗначение(,Элементы.ТаблицаСпецификацийАванса.ТекущиеДанные[Поле.Имя]);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура НомерПоставкиПриИзменении(Элемент)
	
	СписокДоступныхКонтрагентов.Очистить(); 
	Элементы.СписокВыбранныхКонтрагентовЗначение.СписокВыбора.Очистить(); 
	Элементы.СезонПоставки.СписокВыбора.Очистить(); 
	ТаблицаСпецификацийПоставки.Очистить();
	
	КонтрагентПоставки = Неопределено;
	СезонПоставки = Неопределено;
	Элементы.СезонПоставки.РежимВыбораИзСписка = Ложь;
	Элементы.КонтрагентПоставки.РежимВыбораИзСписка = Ложь;
	
	Если ЗначениеЗаполнено(НомерПоставки) Тогда 
		
		ПолучитьДанныеПоПТУ();
		Элементы.СезонПоставки.РежимВыбораИзСписка = Истина; 
		Элементы.КонтрагентПоставки.РежимВыбораИзСписка = Истина;

	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПолучитьДанныеПоПТУ()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ Разрешенные
	|	УпаковочныйЛист.Ссылка КАК Ссылка,
	|	УпаковочныйЛист.гф_Заказ.Контрагент КАК Контрагент,
	|	УпаковочныйЛист.гф_Заказ.Договор КАК Договор,
	|	УпаковочныйЛист.гф_Заказ.Договор.гф_Сезон КАК Сезон
	|ПОМЕСТИТЬ втРез
	|ИЗ
	|	Документ.УпаковочныйЛист КАК УпаковочныйЛист
	|ГДЕ
	|	УпаковочныйЛист.гф_Поставка = &гф_Поставка
	|	И НЕ УпаковочныйЛист.ПометкаУдаления
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втРез.Контрагент КАК Контрагент
	|ИЗ
	|	втРез КАК втРез
	|
	|СГРУППИРОВАТЬ ПО
	|	втРез.Контрагент
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втРез.Сезон КАК Сезон
	|ИЗ
	|	втРез КАК втРез
	|
	|СГРУППИРОВАТЬ ПО
	|	втРез.Сезон";	
	Запрос.УстановитьПараметр("гф_Поставка", НомерПоставки);
	
	ПакетЗапроса = Запрос.ВыполнитьПакет(); 
	
	ТзКонтрагентов = ПакетЗапроса[1].Выгрузить();
	МассивЗаполнения = ТзКонтрагентов.ВыгрузитьКолонку("Контрагент");
	СписокДоступныхКонтрагентов.ЗагрузитьЗначения(МассивЗаполнения); 
	Элементы.КонтрагентПоставки.СписокВыбора.ЗагрузитьЗначения(МассивЗаполнения);
	Элементы.СписокВыбранныхКонтрагентовЗначение.СписокВыбора.ЗагрузитьЗначения(МассивЗаполнения);
	
	ТзСезонов = ПакетЗапроса[2].Выгрузить();
	Элементы.СезонПоставки.СписокВыбора.ЗагрузитьЗначения(ТзСезонов.ВыгрузитьКолонку("Сезон"));
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборПоСпискуПриИзменении(Элемент)
	
	Элементы.КонтрагентПоставки.Доступность = Не ОтборПоСписку;
	Элементы.СписокВыбранныхКонтрагентов.Видимость = ОтборПоСписку;
	
	Если Не ОтборПоСписку Тогда
		СписокВыбранныхКонтрагентов.Очистить();
	КонецЕсли;
	 
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаСпецификацийПоставкиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка) 
	
	Если Поле.Имя = "ТаблицаСпецификацийПоставкиДоговор"	
		Или Поле.Имя = "ТаблицаСпецификацийПоставкиКонтрагент"
		Или Поле.Имя = "ТаблицаСпецификацийПоставкиПТУ"
		Тогда
		
		ИмяПоля = СтрЗаменить(Поле.Имя, "ТаблицаСпецификацийПоставки", "" );
		ПоказатьЗначение(,Элементы.ТаблицаСпецификацийПоставки.ТекущиеДанные[ИмяПоля]);
		
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура ПериодЗаполненияПоставкиПриИзменении(Элемент) 
	
	ДатаНачалаПоставки = ПериодЗаполненияПоставки.ДатаНачала;
	ДатаОкончанияПоставки = ПериодЗаполненияПоставки.ДатаОкончания;
	
КонецПроцедуры
