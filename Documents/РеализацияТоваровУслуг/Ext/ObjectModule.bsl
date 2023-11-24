﻿
&После("ОбработкаПроведения")
Процедура гф_ОбработкаПроведения(Отказ, РежимПроведения)
	// ++ Галфинд СадомцевСА 14.03.2023 Реализовал заполнение Доп. сведения "Срок платежа" при проведении документа
	//e1cib/data/Задача.ЗадачаИсполнителя?ref=812ebcee7bda45d711edbe4fb7595601
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ДополнительныеРеквизитыИСведения.Ссылка КАК Ссылка
	               |ИЗ
	               |	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК ДополнительныеРеквизитыИСведения
	               |ГДЕ
	               |	ДополнительныеРеквизитыИСведения.ИдентификаторДляФормул = &ИдентификаторДляФормул";
	Запрос.УстановитьПараметр("ИдентификаторДляФормул", "гф_РТУСрокПлатежа");
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	Выборка = Результат.Выбрать();
	Если НЕ Выборка.Следующий() Тогда
		Возврат;
	КонецЕсли;
	ДопСведение = Выборка.Ссылка;
	
	ДнейОтсрочкиПлатежа = НайтиКоличествоДнейОтсрочкиПлатежа(Договор);
	
	ДеньВСекундах = 86400;
	СрокПлатежа = Дата + (ДеньВСекундах * ДнейОтсрочкиПлатежа);
	
	НаборЗаписей = РегистрыСведений.ДополнительныеСведения.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Объект.Установить(Ссылка);
	НаборЗаписей.Отбор.Свойство.Установить(ДопСведение);
	Запись = НаборЗаписей.Добавить();
	Запись.Объект = Ссылка;
	Запись.Свойство = ДопСведение;
	Запись.Значение = СрокПлатежа;
	НаборЗаписей.Записать();
	// -- Галфинд СадомцевСА 14.03.2023
КонецПроцедуры

Функция НайтиКоличествоДнейОтсрочкиПлатежа(Договор)
	Если Не ЗначениеЗаполнено(Договор) Тогда
		Возврат 0;
	КонецЕсли;
	ДопРеквизит = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("ИдентификаторДляФормул",
		"гф_ДоговорыКонтрагентовКоличествоДнейОтсрочкиПлатежа");
	КоличествоДнейОтсрочкиПлатежа = УправлениеСвойствами.ЗначениеСвойства(Договор, ДопРеквизит);
	Если ЗначениеЗаполнено(КоличествоДнейОтсрочкиПлатежа) Тогда
		Возврат КоличествоДнейОтсрочкиПлатежа;
	Иначе
		Возврат 0;
	КонецЕсли;
КонецФункции

&После("ОбработкаУдаленияПроведения")
Процедура гф_ОбработкаУдаленияПроведения(Отказ)
	// ++ Галфинд СадомцевСА 14.03.2023 Реализовал удаление Доп. сведения "Срок платежа" при отмене проведения документа
	//e1cib/data/Задача.ЗадачаИсполнителя?ref=812ebcee7bda45d711edbe4fb7595601
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ДополнительныеРеквизитыИСведения.Ссылка КАК Ссылка
	               |ИЗ
	               |	ПланВидовХарактеристик.ДополнительныеРеквизитыИСведения КАК ДополнительныеРеквизитыИСведения
	               |ГДЕ
	               |	ДополнительныеРеквизитыИСведения.ИдентификаторДляФормул = &ИдентификаторДляФормул";
	Запрос.УстановитьПараметр("ИдентификаторДляФормул", "гф_РТУСрокПлатежа");
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	Выборка = Результат.Выбрать();
	Если НЕ Выборка.Следующий() Тогда
		Возврат;
	КонецЕсли;
	ДопСведение = Выборка.Ссылка;
	
	//ДнейОтсрочкиПлатежа = НайтиКоличествоДнейОтсрочкиПлатежа(Договор);
	//
	//СрокПлатежа = Дата + ДнейОтсрочкиПлатежа;
	//
	НаборЗаписей = РегистрыСведений.ДополнительныеСведения.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Объект.Установить(Ссылка);
	НаборЗаписей.Отбор.Свойство.Установить(ДопСведение);
	//Запись = НаборЗаписей.Добавить();
	//Запись.Объект = Ссылка;
	//Запись.Свойство = ДопСведение;
	//Запись.Значение = СрокПлатежа;
	НаборЗаписей.Записать();
	// -- Галфинд СадомцевСА 14.03.2023
КонецПроцедуры

// Галфинд СадомцевСА 04.07.2023 Реализовал создание документа Маркировка товаров ИСМП на основании РТУ
//e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee166b434dc8ce
Процедура СоздатьМаркировкаТоваровИСМП()
	Если ЗначениеЗаполнено(Ссылка.гф_МаркировкаТоваровИСМП) Тогда
		Возврат;
	КонецЕсли;
	// Документ требуется создавать только если склад отгрузки в РТУ имеет признак "Товары в коробах"=Да,
	// а Договор в РТУ имеет признак "Отгрузка кодов маркировки парами" =Нет.
	флТоварыВКоробах = УправлениеСвойствами.ЗначениеСвойства(Склад, "гф_СкладыТоварыВКоробах"); 
	Если Не флТоварыВКоробах = Истина Тогда
		Возврат;
	КонецЕсли;
	флОтгрузкаПарами = УправлениеСвойствами.ЗначениеСвойства(Договор, "гф_ДоговорыКонтрагентовОтгрузкаКодовМаркировкиПарами"); 
	Если флОтгрузкаПарами = Истина Тогда
		Возврат;
	КонецЕсли;
	// СадомцевСА 24.11.2023
	// Необходимо добавить дополнительно в условие создания документа "Маркировка товаров ИС МП":
	// Договор в РТУ имеет признак "Первичные документы в коробах" =Да.
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee89dd37903416
	флПервичныеДокументыВКоробах = УправлениеСвойствами.ЗначениеСвойства(Договор, "гф_ДоговорыКонтрагентовПервичныеДокументыВКоробах");
	Если Не флПервичныеДокументыВКоробах = Истина Тогда
		Возврат;
	КонецЕсли;

	МассивМаркировки = Новый Массив;
	СтруктураВозврата = гф_МаркировкаТоваровИСМПВызовСервера.гф_СоздатьМаркировкаТоваровИСМП_ОснованиеРТУ(Ссылка);
	Если ЗначениеЗаполнено(СтруктураВозврата["МаркировкаТоваровИСМП"])
		И СтруктураВозврата["ЕстьОшибкиЗаполнения"] = Ложь Тогда
		МассивМаркировки.Добавить(СтруктураВозврата["МаркировкаТоваровИСМП"]);
		// сохраняем ссылку на маркировку в РТУ
		гф_МаркировкаТоваровИСМП = СтруктураВозврата["МаркировкаТоваровИСМП"];
		РегистрыСведений.СтатусыПроверкиИПодбораДокументовИСМП.ОтразитьЗавершениеПроверкиДокумента(
			гф_МаркировкаТоваровИСМП,
			гф_МаркировкаТоваровИСМП.ВидПродукции,
			Неопределено,
			Перечисления.ТребуемоеДействиеДокументЭДО.Подтвердить);
	КонецЕсли;
	Если МассивМаркировки.Количество() > 0 Тогда
		гф_МаркировкаТоваровИСМПВызовСервера.гф_ПодготовитьКПередачеИСМП(МассивМаркировки);
	КонецЕсли;
КонецПроцедуры

&После("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	// ++ Галфинд СадомцевСА 04.07.2023 Реализовал создание документа Маркировка товаров ИСМП на основании РТУ
	//e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee166b434dc8ce
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		СоздатьМаркировкаТоваровИСМП();
	КонецЕсли;
	// -- Галфинд СадомцевСА 04.07.2023
КонецПроцедуры
