﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Объект.РежимРаботы = 0;
	
КонецПроцедуры

&НаКлиенте
Процедура Заполнить(Команда)
	
	ТаблицаСпецификацийАванса.Очистить();
	
	Если Объект.РежимРаботы = 0 Тогда
		
		Если Объект.ДатаНачала = Дата(1,1,1) Или Объект.ДатаОкончания = Дата(1,1,1) Тогда
			Сообщить("Выберите период заполнения!");
			Возврат;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(Объект.Сезон) Тогда
			Сообщить("Выберите не пустой сезон!");
			Возврат;
		КонецЕсли;

		ЗаполнитьНаАвансНаСервере(); 
		
	ИначеЕсли Объект.РежимРаботы = 1 Тогда 
		
		ЗаполнитьНаПоставкуНаСервере(); 
		
	КонецЕсли; 
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаАвансНаСервере()

	ТаблицаСпецификацийАванса.Очистить();;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
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
	|	Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втСпецификации.Договор КАК Договор,
	|	ДополнительныеСведенияСтраховойДепозит.Значение КАК СтраховойДепозит,
	|	ДополнительныеСведенияПредоплата.Значение КАК Предоплата
	|ПОМЕСТИТЬ втСвойстваДоговора
	|ИЗ
	|	втСпецификации КАК втСпецификации
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведенияСтраховойДепозит
	|		ПО втСпецификации.Договор = ДополнительныеСведенияСтраховойДепозит.Объект
	|			И (ДополнительныеСведенияСтраховойДепозит.Свойство = &СвойствоСтраховойДепозит)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведенияПредоплата
	|		ПО втСпецификации.Договор = ДополнительныеСведенияПредоплата.Объект
	|			И (ДополнительныеСведенияПредоплата.Свойство = &СвойствоПредоплата)
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
	|ВЫБРАТЬ
	|	ИСТИНА КАК Пометка,
	|	втСпецификации.Ссылка КАК Спецификация,
	|	втСпецификации.Контрагент КАК Контрагент,
	|	втСпецификации.Организация КАК Организация,
	|	втСпецификации.Договор КАК Договор,
	|	втСпецификации.Сумма КАК Сумма,
	|	втСвойстваДоговора.СтраховойДепозит КАК УслугаДепозита,
	|	втСвойстваДоговора.Предоплата КАК УслугаПредоплаты,
	|	гф_ПроцентыПредоплатыПоДепозиту.Процент КАК Депозит,
	|	гф_ПроцентыПредоплатыСкидкаЗаПредоплату.ПроцентСкидки КАК Предоплата
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
	|	гф_ПроцентыПредоплатыСкидкаЗаПредоплату.ПроцентСкидки,
	|	втСпецификации.Сумма";
	
	Запрос.УстановитьПараметр("Сезон", Объект.Сезон);
	Запрос.УстановитьПараметр("ДатаНачала", Объект.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", Объект.ДатаОкончания);  
	Запрос.УстановитьПараметр("СвойствоСтраховойДепозит", ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоНаименованию("Страховой депозит"));  
	Запрос.УстановитьПараметр("СвойствоПредоплата", ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоНаименованию("Предоплата"));  

	ТзЗапроса = Запрос.Выполнить().Выгрузить();  
	
	Если ТзЗапроса.Количество() = 0 Тогда
		Сообщить("Нет данных для заполнения!");
	КонецЕсли;
	
	ТаблицаСпецификацийАванса.Загрузить(ТзЗапроса); 

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНаПоставкуНаСервере()

	ТаблицаСпецификацийПоставки.Очистить();

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	гф_СпецификацияПокупателя.Ссылка КАК Ссылка,
	|	гф_СпецификацияПокупателя.Контрагент КАК Контрагент,
	|	гф_СпецификацияПокупателя.Организация КАК Организация,
	|	гф_СпецификацияПокупателя.Договор КАК Договор
	|ПОМЕСТИТЬ втСпецификации
	|ИЗ
	|	Документ.гф_СпецификацияПокупателя КАК гф_СпецификацияПокупателя
	|ГДЕ
	|	гф_СпецификацияПокупателя.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания
	|	И гф_СпецификацияПокупателя.Договор.гф_Сезон = &Сезон
	|	И гф_СпецификацияПокупателя.Проведен
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИСТИНА КАК Пометка,
	|	втСпецификации.Ссылка КАК Спецификация,
	|	втСпецификации.Контрагент КАК Контрагент,
	|	втСпецификации.Организация КАК Организация,
	|	втСпецификации.Договор КАК Договор,
	|	СУММА(гф_СпецификацияПокупателяЗаказыКлиентов.ЗаказКлиента.СуммаДокумента) КАК Сумма
	|ИЗ
	|	втСпецификации КАК втСпецификации
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.гф_СпецификацияПокупателя.ЗаказыКлиентов КАК гф_СпецификацияПокупателяЗаказыКлиентов
	|		ПО (втСпецификации.Ссылка = гф_СпецификацияПокупателяЗаказыКлиентов.Ссылка)
	|
	|СГРУППИРОВАТЬ ПО
	|	втСпецификации.Ссылка,
	|	втСпецификации.Контрагент,
	|	втСпецификации.Организация,
	|	втСпецификации.Договор";
	
	Запрос.УстановитьПараметр("Сезон", Объект.Сезон);
	Запрос.УстановитьПараметр("ДатаНачала", Объект.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", Объект.ДатаОкончания);  
	
	ТзЗапроса = Запрос.Выполнить().Выгрузить();
	ТаблицаСпецификацийАванса.Загрузить(ТзЗапроса); 

КонецПроцедуры

&НаКлиенте
Процедура ПериодЗаполненияПриИзменении(Элемент)

	Объект.ДатаНачала = ПериодЗаполнения.ДатаНачала;
	Объект.ДатаОкончания = ПериодЗаполнения.ДатаОкончания;
	
КонецПроцедуры

&НаКлиенте
Процедура Сформировать(Команда)
	
	СтрокаОшибок = "";
	
	Если Объект.РежимРаботы = 0 Тогда		
		СтрокаОшибок = СформироватьНаАвансНаСервере();		
	ИначеЕсли Объект.РежимРаботы = 1 Тогда
		
	КонецЕсли;  
	
	Если не ПустаяСтрока(СтрокаОшибок) Тогда
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
			
			СчетСсылка = НайтиСчетНаОплату(Элемент.Спецификация, Элемент.УслугаДепозита);
			
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
			
			ДокументСчет.НазначениеПлатежа = Элемент.УслугаДепозита.Наименование + " " + ДоговорКонтрагента;
			ДокументСчет.Контрагент = Элемент.Контрагент; 
			ДокументСчет.Партнер = Элемент.Контрагент.Партнер; 
			
			ДокументСчет.гф_СпецификацияПокупателя = Элемент.Спецификация;
			ДокументСчет.Автор = ТекущийПользователь;
			
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
			
			СчетСсылка = НайтиСчетНаОплату(Элемент.Спецификация, Элемент.УслугаПредоплаты);
			
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
			
			ДокументСчет.НазначениеПлатежа = Элемент.УслугаПредоплаты.Наименование + " " + ДоговорКонтрагента;
			ДокументСчет.Контрагент = Элемент.Контрагент; 
			ДокументСчет.Партнер = Элемент.Контрагент.Партнер;   
			
			ДокументСчет.гф_СпецификацияПокупателя = Элемент.Спецификация;
			ДокументСчет.Автор = ТекущийПользователь;
			
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
Функция НайтиСчетНаОплату(СпецификацияСсылка, НазначениеПлатежа) 
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СчетНаОплатуКлиенту.Ссылка КАК Ссылка
	|ИЗ
	|	Документ.СчетНаОплатуКлиенту КАК СчетНаОплатуКлиенту
	|ГДЕ
	|	СчетНаОплатуКлиенту.гф_СпецификацияПокупателя = &СпецификацияСсылка
	|	И СчетНаОплатуКлиенту.НазначениеПлатежа Подобно &НазначениеПлатежа
	|	И Не СчетНаОплатуКлиенту.ПометкаУдаления";
	Запрос.УстановитьПараметр("СпецификацияСсылка", СпецификацияСсылка);
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

&НаКлиенте
Процедура УстановитьФлажки(Команда)
	
	Если Объект.РежимРаботы = 0 Тогда
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
	
	Если Объект.РежимРаботы = 0 Тогда
		Для Каждого Элемент Из ТаблицаСпецификацийАванса Цикл
			Элемент.Пометка = Ложь;
		КонецЦикла;
	Иначе
		Для Каждого Элемент Из ТаблицаСпецификацийПоставки Цикл
			Элемент.Пометка = Ложь;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура РежимРаботыПриИзменении(Элемент)
	
	Если Объект.РежимРаботы = 0 Тогда 
		Элементы.СтраницаНаАванс.Видимость = Истина;
		Элементы.СтраницаНаПоставку.Видимость = Ложь;
	Иначе
		Элементы.СтраницаНаАванс.Видимость = Ложь;
		Элементы.СтраницаНаПоставку.Видимость = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаСпецификацийВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если Поле.Имя = "Договор"	
		Или Поле.Имя = "Контрагент"
		Или Поле.Имя = "Спецификация"
		Или Поле.Имя = "УслугаДепозита"
		Или Поле.Имя = "УслугаПредоплаты" Тогда
		
		ПоказатьЗначение(,Элементы.ТаблицаСпецификаций.ТекущиеДанные[Поле.Имя]);
		
	КонецЕсли;
	
КонецПроцедуры
