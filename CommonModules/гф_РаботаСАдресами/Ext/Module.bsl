﻿#Область ПрограммныйИнтерфейс

// Заполняет реквизит по типу документа, прочитанные из информационной базы по ссылке на объект.
// Параметры:
//  АдресДоставкиЗначение    - Строка - значения которое необходимо получить.
Функция ИндексАдресаКонтактнойИнформации(АдресДоставкиЗначение) Экспорт

	Возврат РаботаСАдресами.СведенияОбАдресе(АдресДоставкиЗначение).Индекс;

КонецФункции

// Заполняет реквизит по типу документа, прочитанные из информационной базы по ссылке на объект.
// Параметры:
//  ИсходнаяСтрока    - Строка - значения которое необходимо получить.
//  РазделительРазрядов  - Строка   - значения которое необходимо получить.
//  НомерРазряда    - Строка - значения которое необходимо получить.
Функция ВыделитьПодстрокуПоНомеруРазряда(ИсходнаяСтрока, РазделительРазрядов, НомерРазряда) Экспорт
	
	НомерПрохода = 1;
	ИзменяемаяСтрока = ИсходнаяСтрока;
	ПозицияРазделителя = Найти(ИзменяемаяСтрока,РазделительРазрядов);
	Результат = Лев(ИзменяемаяСтрока,ПозицияРазделителя-1);
	Если НомерРазряда = НомерПрохода Тогда
		Возврат Результат;
	КонецЕсли;
	
	Пока ПозицияРазделителя > 0 Цикл  
		Результат = Лев(ИзменяемаяСтрока,ПозицияРазделителя-1);
		ИзменяемаяСтрока = Прав(ИзменяемаяСтрока,СтрДлина(ИзменяемаяСтрока)-ПозицияРазделителя);
		ПозицияРазделителя = Найти(ИзменяемаяСтрока,РазделительРазрядов);
		Если НомерРазряда = НомерПрохода Тогда
			Возврат Результат;
		КонецЕсли;
		НомерПрохода = НомерПрохода + 1;
	КонецЦикла;

	Возврат Результат;

КонецФункции

Процедура ОчиститьРеквизит(ОчишаемыйРеквизит)
	
	Если ТипЗнч(ОчишаемыйРеквизит) = Тип("СправочникСсылка.Партнеры") Тогда
		ОчишаемыйРеквизит = Справочники.Партнеры.ПустаяСсылка();
	ИначеЕсли ТипЗнч(ОчишаемыйРеквизит) = Тип("СправочникСсылка.Контрагенты") Тогда
		ОчишаемыйРеквизит = Справочники.Контрагенты.ПустаяСсылка();
	ИначеЕсли ТипЗнч(ОчишаемыйРеквизит) = Тип("СправочникСсылка.гф_АдресаДоставки") Тогда
		ОчишаемыйРеквизит = Справочники.гф_АдресаДоставки.ПустаяСсылка();
	КонецЕсли;
	
КонецПроцедуры

// Заполняет реквизит по типу документа, прочитанные из информационной базы по ссылке на объект.
// Параметры:
//  Ссылка    - ЛюбаяСсылка - объект, значения реквизитов которого необходимо получить.
//            - Строка      - полное имя предопределенного элемента, значения реквизитов которого необходимо получить.
Процедура ПартнерПриИзмененииНаФормеДокумента(Объект) Экспорт
	
	Если ТипЗнч(Объект.Ссылка) = Тип("ДокументСсылка.ВнутреннееПотребление")
		Или ТипЗнч(Объект.Ссылка) = Тип("ДокументСсылка.ЗаказНаВнутреннееПотребление") Тогда
		
		ПартнерыИКонтрагенты.ЗаполнитьКонтрагентаПартнераПоУмолчанию(Объект.гф_Партнер, Объект.гф_Контрагент, Истина);
		
		Если Не ЗначениеЗаполнено(Объект.гф_Партнер) Тогда
			ОчиститьРеквизит(Объект.гф_Контрагент);
			ОчиститьРеквизит(Объект.гф_АдресДоставки);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Объект.гф_Партнер) И Не ЗначениеЗаполнено(Объект.гф_Контрагент) Тогда
			
			ОчиститьРеквизит(Объект.гф_Партнер);
			ОчиститьРеквизит(Объект.гф_АдресДоставки);
			
			Если ТипЗнч(Объект.Ссылка) = Тип("ДокументСсылка.ВнутреннееПотребление") Тогда
				ОчиститьРеквизит(Объект.гф_ТК);
			КонецЕсли;
			
			СообщитьОНарушенииСвязиПартнерКонтрагент();
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Объект.гф_Партнер)
			И ЗначениеЗаполнено(Объект.гф_Контрагент)
			И ЗначениеЗаполнено(Объект.гф_АдресДоставки) Тогда
			
			АдресСоответствует = ПроверитьСоответствиеАдресаВладельцу(Объект.Контрагент, Объект.гф_АдресДоставки);
			
			Если Не АдресСоответствует Тогда
				
				ОчиститьРеквизит(Объект.гф_АдресДоставки);
				
			КонецЕсли;
			
		КонецЕсли;
				
	ИначеЕсли ТипЗнч(Объект.Ссылка) = Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда
		
		Если Не ЗначениеЗаполнено(Объект.Партнер) И ЗначениеЗаполнено(Объект.Контрагент) Тогда
			ОчиститьРеквизит(Объект.Контрагент);
			ОчиститьРеквизит(Объект.гф_АдресДоставки);
		ИначеЕсли Не ЗначениеЗаполнено(Объект.Партнер) Тогда	
			ОчиститьРеквизит(Объект.гф_АдресДоставки);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Объект.Партнер) И Не ЗначениеЗаполнено(Объект.Контрагент) Тогда
			
			ОчиститьРеквизит(Объект.гф_АдресДоставки);
			
			СообщитьОНарушенииСвязиПартнерКонтрагент();
			
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Объект.Партнер)
			И ЗначениеЗаполнено(Объект.Контрагент)
			И ЗначениеЗаполнено(Объект.гф_АдресДоставки) Тогда
			
			АдресСоответствует = ПроверитьСоответствиеАдресаВладельцу(Объект.Контрагент, Объект.гф_АдресДоставки);
			
			Если Не АдресСоответствует Тогда
				
				ОчиститьРеквизит(Объект.гф_АдресДоставки);
				
			КонецЕсли;
			
		КонецЕсли;
			
	КонецЕсли;

КонецПроцедуры

// Заполняет реквизит по типу документа, прочитанные из информационной базы по ссылке на объект.
// Параметры:
//  Ссылка    - ЛюбаяСсылка - объект, значения реквизитов которого необходимо получить.
//            - Строка      - полное имя предопределенного элемента, значения реквизитов которого необходимо получить.
Процедура АдресДоставкиПриИзмененииНаФормеДокумента(Объект) Экспорт
	
	Если ТипЗнч(Объект.Ссылка) = Тип("ДокументСсылка.ВнутреннееПотребление") Тогда
		
		Если Не ЗначениеЗаполнено(Объект.гф_АдресДоставки) Тогда
			ОчиститьРеквизит(Объект.гф_ТК);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// Заполняет реквизит по типу документа, прочитанные из информационной базы по ссылке на объект.
// Параметры:
//  Ссылка    - ЛюбаяСсылка - объект, значения реквизитов которого необходимо получить.
//            - Строка      - полное имя предопределенного элемента, значения реквизитов которого необходимо получить.
Процедура АдресДоставкиНачалоВыбораНаФормеДокумента(Объект) Экспорт
	
	Если ТипЗнч(Объект.Ссылка) = Тип("ДокументСсылка.ВнутреннееПотребление")
		Или ТипЗнч(Объект.Ссылка) = Тип("ДокументСсылка.ЗаказНаВнутреннееПотребление") Тогда
		
		Если ТипЗнч(Объект.Ссылка) = Тип("ДокументСсылка.ВнутреннееПотребление")
			И Не ЗначениеЗаполнено(Объект.гф_АдресДоставки) Тогда
			ОчиститьРеквизит(Объект.гф_ТК);
		КонецЕсли;
		
		Если (Не ЗначениеЗаполнено(Объект.гф_Партнер) И Не ЗначениеЗаполнено(Объект.гф_Контрагент))
			Или (Не ЗначениеЗаполнено(Объект.гф_Партнер) И ЗначениеЗаполнено(Объект.гф_Контрагент)) Тогда
			
			ТекстСообщения = НСтр("ru = 'Не заполнен клиент!'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
			СтандартнаяОбработка = Ложь;
			Возврат;
			
		ИначеЕсли ЗначениеЗаполнено(Объект.гф_Партнер) И Не ЗначениеЗаполнено(Объект.гф_Контрагент) Тогда
			
			ТекстСообщения = НСтр("ru = 'Необходимо перевыбрать клиента для заполнения данных для отбора адресов доставки!'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
			СтандартнаяОбработка = Ложь;
			Возврат;
			
		КонецЕсли;
		
	ИначеЕсли ТипЗнч(Объект.Ссылка) = Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда	
		
		Если Не ЗначениеЗаполнено(Объект.Партнер) И Не ЗначениеЗаполнено(Объект.Контрагент) Тогда
			
			ТекстСообщения = НСтр("ru = 'Не заполнен клиент!'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
			СтандартнаяОбработка = Ложь;
			Возврат;
			
		ИначеЕсли ЗначениеЗаполнено(Объект.Партнер) И Не ЗначениеЗаполнено(Объект.Контрагент) Тогда
			
			ТекстСообщения = НСтр("ru = 'Необходимо перевыбрать клиента для заполнения данных для отбора адресов доставки!'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
			СтандартнаяОбработка = Ложь;
			Возврат;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ДополнительныеПроцедурыИФункции

Функция ПроверитьСоответствиеАдресаВладельцу(Контрагент, АдресДоставки)
	
	Если Не АдресДоставки.Владелец = Контрагент Тогда
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции

Процедура СообщитьОНарушенииСвязиПартнерКонтрагент()
    ТекстСообщения = НСтр("ru = 'По данному клиенту не возможно заполнить данные отбора по адресам доставки, нарушена связь в справочниках ""Партнеры"" и ""Контрагенты""!'");
	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
КонецПроцедуры

#КонецОбласти