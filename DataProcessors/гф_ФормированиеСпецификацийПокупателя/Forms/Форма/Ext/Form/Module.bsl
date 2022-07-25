﻿#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаОтметитьВсе(Команда)
	
	Для Каждого Строка Из Объект.Спецификации Цикл
		
		Строка.Флаг = Истина;	
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаСнятьВсеОтметки(Команда)
	
	Для Каждого Строка Из Объект.Спецификации Цикл
		
		Строка.Флаг = Ложь;	
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура КомандаЗаполнитьНаСервере()
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	ЗаказКлиента.Контрагент КАК Контрагент,
	               |	ЗаказКлиента.Договор КАК Договор,
	               |	ЗаказКлиента.Ссылка КАК Заказ
	               |ПОМЕСТИТЬ ВТ_Заказы
	               |ИЗ
	               |	Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК ЗаказКлиента
	               |			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	               |			ПО ЗаказКлиента.Договор = ДоговорыКонтрагентов.Ссылка
	               |		ПО ЗаказКлиентаТовары.Ссылка = ЗаказКлиента.Ссылка
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК НоменклатураЗаказа
	               |		ПО ЗаказКлиентаТовары.Номенклатура = НоменклатураЗаказа.Ссылка
	               |ГДЕ
	               |	ЗаказКлиента.Организация = &Организация
	               |	И ЗаказКлиента.гф_СтатусРаботыСЗаказомИ5 = ЗНАЧЕНИЕ(Перечисление.гф_СтатусРаботыСЗаказомИ5.Подтвержден)
	               |	И ЗаказКлиента.Склад = &Склад
	               |	И (ДоговорыКонтрагентов.гф_Сезон = &Сезон
	               |			ИЛИ &Сезон = ЗНАЧЕНИЕ(Справочник.КоллекцииНоменклатуры.ПустаяСсылка))
	               |	И ЗаказКлиента.Проведен
	               |	И НоменклатураЗаказа.ВидНоменклатуры = &ВидНоменклатуры
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_Заказы.Контрагент КАК Контрагент,
	               |	ВТ_Заказы.Договор КАК Договор,
	               |	МАКСИМУМ(гф_СпецификацияПокупателяЗаказыКлиентов.Ссылка) КАК Ссылка
	               |ПОМЕСТИТЬ ВТ_Спецификации
	               |ИЗ
	               |	ВТ_Заказы КАК ВТ_Заказы
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.гф_СпецификацияПокупателя.ЗаказыКлиентов КАК гф_СпецификацияПокупателяЗаказыКлиентов
	               |			ЛЕВОЕ СОЕДИНЕНИЕ Документ.гф_СпецификацияПокупателя КАК гф_СпецификацияПокупателя
	               |			ПО гф_СпецификацияПокупателяЗаказыКлиентов.Ссылка = гф_СпецификацияПокупателя.Ссылка
	               |		ПО ВТ_Заказы.Заказ = гф_СпецификацияПокупателяЗаказыКлиентов.ЗаказКлиента
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВТ_Заказы.Контрагент,
	               |	ВТ_Заказы.Договор
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_Заказы.Контрагент КАК Контрагент,
	               |	ВТ_Заказы.Договор КАК ДоговорКонтрагента,
	               |	ВТ_Заказы.Заказ КАК ЗаказКлиента
	               |ИЗ
	               |	ВТ_Заказы КАК ВТ_Заказы
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ИСТИНА КАК Флаг,
	               |	ВТ_Спецификации.Контрагент КАК Контрагент,
	               |	ВТ_Спецификации.Договор КАК ДоговорКонтрагента,
	               |	ВТ_Спецификации.Ссылка КАК СпецификацияПокупателя,
	               |	гф_СпецификацияПокупателя.Проведен КАК Проведен,
	               |	гф_СпецификацияПокупателя.ПометкаУдаления КАК ПометкаУдаления,
	               |	ВЫБОР
	               |		КОГДА гф_СпецификацияПокупателя.Проведен
	               |			ТОГДА 1
	               |		КОГДА гф_СпецификацияПокупателя.ПометкаУдаления
	               |			ТОГДА 2
	               |		ИНАЧЕ 0
	               |	КОНЕЦ КАК ИндексКартинки
	               |ИЗ
	               |	ВТ_Спецификации КАК ВТ_Спецификации
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.гф_СпецификацияПокупателя КАК гф_СпецификацияПокупателя
	               |		ПО ВТ_Спецификации.Ссылка = гф_СпецификацияПокупателя.Ссылка";   
	
	Запрос.Параметры.Вставить("Организация", Объект.Организация);
	Запрос.Параметры.Вставить("Склад", Объект.Склад);
	Запрос.Параметры.Вставить("Сезон", Объект.Сезон);
	Запрос.Параметры.Вставить("ВидНоменклатуры", Объект.ВидНоменклатуры);
	
	ПакетРезультатов = Запрос.ВыполнитьПакет();
	
	СмещениеЗаказов = 2;
	СмещениеСпецификаций = 1;
	
	ИндексЗаказов = ПакетРезультатов.Количество() - СмещениеЗаказов;
	ИндексСпецификаций = ПакетРезультатов.Количество() - СмещениеСпецификаций;
	
	Объект.Заказы.Загрузить(ПакетРезультатов[ИндексЗаказов].Выгрузить());
	Объект.Спецификации.Загрузить(ПакетРезультатов[ИндексСпецификаций].Выгрузить());
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаЗаполнить(Команда)
	
	КомандаЗаполнитьНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура КомандаСоздатьСпецификацииНаСервере()
	
	Для Каждого СтрокаСпецификации Из Объект.Спецификации Цикл
		
		Если Не СтрокаСпецификации.Флаг Тогда
			
			Продолжить;
			
		КонецЕсли;	
		
		Если СтрокаСпецификации.Проведен Тогда
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("По контрагенту " + 
				СтрокаСпецификации.Контрагент + " в табличной части присутствуют проведенные спецификации");
			
			Продолжить;
			
		КонецЕсли;	        

		Если ЗначениеЗаполнено(СтрокаСпецификации.СпецификацияПокупателя) Тогда
			
			СпецификацияОбъект = СтрокаСпецификации.СпецификацияПокупателя.ПолучитьОбъект();
			
			СпецификацияОбъект.ПометкаУдаления = Ложь;
			
			СпецификацияОбъект.ЗаказыКлиентов.Очистить();
			
		Иначе	
			
			СпецификацияОбъект = Документы.гф_СпецификацияПокупателя.СоздатьДокумент();
			
		КонецЕсли;
		
		ОтборЗаказов = Новый Структура("Контрагент, ДоговорКонтрагента",
										СтрокаСпецификации.Контрагент,
										СтрокаСпецификации.ДоговорКонтрагента);
										
		СтрокиЗаказов = Объект.Заказы.НайтиСтроки(ОтборЗаказов);										
		
		СпецификацияОбъект.Организация		= Объект.Организация;
		СпецификацияОбъект.Контрагент		= СтрокаСпецификации.Контрагент;
		СпецификацияОбъект.Договор			= СтрокаСпецификации.ДоговорКонтрагента;
		СпецификацияОбъект.Ответственный	= Пользователи.ТекущийПользователь();
		СпецификацияОбъект.Дата				= ТекущаяДатаСеанса();
		
		Для Каждого СтрокаЗаказа Из СтрокиЗаказов Цикл
			
			СтрокаДокумента = СпецификацияОбъект.ЗаказыКлиентов.Добавить();
			
			СтрокаДокумента.ЗаказКлиента = СтрокаЗаказа.ЗаказКлиента;
			
		КонецЦикла;	
		
		СпецификацияОбъект.Записать();
		
		СтрокаСпецификации.СпецификацияПокупателя = СпецификацияОбъект.Ссылка;
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаСоздатьСпецификации(Команда)

	КомандаСоздатьСпецификацииНаСервере();

КонецПроцедуры

&НаСервере
Процедура КомандаПровестиНаСервере()

	Для Каждого СтрокаСпецификации Из Объект.Спецификации Цикл
		
		Если Не СтрокаСпецификации.Флаг Тогда
			
			Продолжить;
			
		КонецЕсли;	
		
		СпецификацияОбъект = СтрокаСпецификации.СпецификацияПокупателя.ПолучитьОбъект();
		
		Если Не СпецификацияОбъект.Проведен Тогда  
			
			СпецификацияОбъект.ПометкаУдаления = Ложь;
			
			СпецификацияОбъект.Записать(РежимЗаписиДокумента.Проведение);
			
			УстановитьФлажки(СпецификацияОбъект, СтрокаСпецификации);
			
		КонецЕсли;	
		
	КонецЦикла; 
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаПровести(Команда)
	
	КомандаПровестиНаСервере();
	
	ОповеститьОбИзменении(Тип("ДокументСсылка.гф_СпецификацияПокупателя"));
	
КонецПроцедуры

&НаСервере
Процедура КомандаОтменитьПроведениеНаСервере()
	
	Для Каждого СтрокаСпецификации Из Объект.Спецификации Цикл
		
		Если Не СтрокаСпецификации.Флаг Тогда
			
			Продолжить;
			
		КонецЕсли;	
		
		СпецификацияОбъект = СтрокаСпецификации.СпецификацияПокупателя.ПолучитьОбъект();
		
		Если СпецификацияОбъект.Проведен Тогда  
			
			СпецификацияОбъект.Записать(РежимЗаписиДокумента.ОтменаПроведения);
			
			УстановитьФлажки(СпецификацияОбъект, СтрокаСпецификации);
			
		КонецЕсли;	
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаОтменитьПроведение(Команда)

	КомандаОтменитьПроведениеНаСервере();

	ОповеститьОбИзменении(Тип("ДокументСсылка.гф_СпецификацияПокупателя"));
	
КонецПроцедуры

&НаСервере
Процедура КомандаПометитьНаУдалениеНаСервере()

	Для Каждого СтрокаСпецификации Из Объект.Спецификации Цикл
		
		Если Не СтрокаСпецификации.Флаг Тогда
			
			Продолжить;
			
		КонецЕсли;	
		
		СпецификацияОбъект = СтрокаСпецификации.СпецификацияПокупателя.ПолучитьОбъект();
		
		Если Не СпецификацияОбъект.ПометкаУдаления Тогда  
			
			СпецификацияОбъект.УстановитьПометкуУдаления(Истина);
			
			УстановитьФлажки(СпецификацияОбъект, СтрокаСпецификации);
			
		КонецЕсли;	
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаПометитьНаУдаление(Команда)

	КомандаПометитьНаУдалениеНаСервере();
	
	ОповеститьОбИзменении(Тип("ДокументСсылка.гф_СпецификацияПокупателя"));
	
КонецПроцедуры

&НаСервере
Процедура КомандаСнятьПометкиНаУдалениеНаСервере()

	Для Каждого СтрокаСпецификации Из Объект.Спецификации Цикл
		
		Если Не СтрокаСпецификации.Флаг Тогда
			
			Продолжить;
			
		КонецЕсли;	
		
		СпецификацияОбъект = СтрокаСпецификации.СпецификацияПокупателя.ПолучитьОбъект();
		
		Если СпецификацияОбъект.ПометкаУдаления Тогда  
			
			СпецификацияОбъект.УстановитьПометкуУдаления(Ложь);
			
			УстановитьФлажки(СпецификацияОбъект, СтрокаСпецификации);
			
		КонецЕсли;	
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаСнятьПометкиНаУдаление(Команда)

	КомандаСнятьПометкиНаУдалениеНаСервере();

	ОповеститьОбИзменении(Тип("ДокументСсылка.гф_СпецификацияПокупателя"));

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура УстановитьФлажки(СпецификацияОбъект, СтрокаСпецификации)
	
	СтрокаСпецификации.Проведен			= СпецификацияОбъект.Проведен;
	СтрокаСпецификации.ПометкаУдаления	= СпецификацияОбъект.ПометкаУдаления;
	
	Если СтрокаСпецификации.Проведен Тогда
		
		СтрокаСпецификации.ИндексКартинки = 1;
		
	ИначеЕсли СтрокаСпецификации.ПометкаУдаления Тогда
		
		СтрокаСпецификации.ИндексКартинки = 2;
		
	Иначе
		
		СтрокаСпецификации.ИндексКартинки = 0;
		
	КонецЕсли;	
	
КонецПроцедуры	

#КонецОбласти

