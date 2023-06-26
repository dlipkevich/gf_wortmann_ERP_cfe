﻿
&После("ПриЗаписи")
Процедура ИК_ПриЗаписи(Отказ)
	
	Если Не Отказ  
		И ДополнительныеСвойства.Свойство("ЭтоНовый")
		И ДополнительныеСвойства.ЭтоНовый Тогда
		
		Организация = "";
		СоответствияНоменклатурныхГруппТоварнымГруппам = Неопределено;
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ ПЕРВЫЕ 1
			|	гф_НастройкиИнтеграции.Организация КАК Организация
			|ИЗ
			|	РегистрСведений.гф_НастройкиИнтеграции КАК гф_НастройкиИнтеграции
			|ГДЕ
			|	гф_НастройкиИнтеграции.ОсновнаяОрганизация";
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Организация = ВыборкаДетальныеЗаписи.Организация;
			
			Набор = РегистрыСведений.гф_НастройкиИнтеграции.СоздатьНаборЗаписей();
			Набор.Отбор.Организация.Установить(Организация);
			Набор.Прочитать();
			Если Набор.Количество() Тогда
				СоответствияНоменклатурныхГруппТоварнымГруппам = Набор[0].СоответствияНоменклатурныхГруппТоварнымГруппам.Получить();
			КонецЕсли;
 
		КонецЦикла;
		
		// vvv Галфинд \ Sakovich 02.03.2023
		//Если СоответствияНоменклатурныхГруппТоварнымГруппам  = Неопределено Тогда
		//	Возврат;
		//КонецЕсли;
		// ^^^ Галфинд \ Sakovich 02.03.2023
		
		//++ЕсипоаАВ Для использования внешней обработки добавлено условие возможности записи 02.06.2023
		Если Не ЭтотОбъект.ЭтотОбъект.ДополнительныеСвойства.Свойство("гф_ВнешняяОбработка", "ОбработкаРеквизитаКоличества") Тогда
			
			Если СоответствияНоменклатурныхГруппТоварнымГруппам  = Неопределено Тогда				
				Возврат;
			КонецЕсли;
		//--ЕсиповАВ 02.06.2023
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	ВариантыКомплектацииНоменклатурыТовары.Номенклатура КАК Номенклатура,
			|	ВариантыКомплектацииНоменклатурыТовары.Характеристика КАК Характеристика
			|ПОМЕСТИТЬ ВТ_Товары
			|ИЗ
			|	&ТЗТовары КАК ВариантыКомплектацииНоменклатурыТовары
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ
			|	ВТ_Товары.Номенклатура КАК Номенклатура,
			|	ВТ_Товары.Характеристика КАК Характеристика,
			|	ВТ_Товары.Номенклатура.ВидНоменклатуры КАК ВидНоменклатуры,
			|	ШтрихкодыНоменклатуры.гф_СостояниеВыгрузкиНоменклатуры КАК гф_СостояниеВыгрузкиНоменклатуры,
			|	ШтрихкодыНоменклатуры.Штрихкод КАК Штрихкод,
			|	ЕСТЬNULL(ДополнительныеСведения.Значение, ДАТАВРЕМЯ(1, 1, 1)) КАК Дата_i5
			|ИЗ
			|	ВТ_Товары КАК ВТ_Товары
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
			|		ПО ВТ_Товары.Номенклатура = ШтрихкодыНоменклатуры.Номенклатура
			|			И ВТ_Товары.Характеристика = ШтрихкодыНоменклатуры.Характеристика
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
			|		ПО ВТ_Товары.Номенклатура = ДополнительныеСведения.Объект
			|			И (ДополнительныеСведения.Свойство.Имя = ""гф_НоменклатураДатаОбновленияНоменклатурыИзI5""
			|				ИЛИ ДополнительныеСведения.Свойство.ИдентификаторДляФормул = ""гф_НоменклатураДатаОбновленияНоменклатурыИзI5"")
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.гф_СтатусыGTIN.СрезПоследних(
			|				,
			|				(Номенклатура, Характеристика) В
			|					(ВЫБРАТЬ
			|						ВТ_Товары.Номенклатура КАК Номенклатура,
			|						ВТ_Товары.Характеристика КАК Характеристика
			|					ИЗ
			|						ВТ_Товары КАК ВТ_Товары)) КАК гф_СтатусыGTINСрезПоследних
			|		ПО ВТ_Товары.Номенклатура = гф_СтатусыGTINСрезПоследних.Номенклатура
			|			И ВТ_Товары.Характеристика = гф_СтатусыGTINСрезПоследних.Характеристика
			|ГДЕ
			|	гф_СтатусыGTINСрезПоследних.Номенклатура ЕСТЬ NULL";
		
		Запрос.УстановитьПараметр("ТЗТовары", Товары.Выгрузить());
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.гф_СостояниеВыгрузкиНоменклатуры)
				И ВыборкаДетальныеЗаписи.гф_СостояниеВыгрузкиНоменклатуры <> Перечисления.гф_СтатусыGTIN_В_НК.Отсутствует Тогда
				Продолжить;
			Иначе
				Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.Дата_i5) Тогда
					СтруктураПоиска = Новый Структура("ВидНоменклатуры", ВыборкаДетальныеЗаписи.ВидНоменклатуры);
					СтрокиПоиска = СоответствияНоменклатурныхГруппТоварнымГруппам.НайтиСтроки(СтруктураПоиска);
					Если СтрокиПоиска.Количество()>0 
						И СтрокиПоиска[0].ЕстьGTIN Тогда
						
						запись = РегистрыСведений.гф_СтатусыGTIN.СоздатьМенеджерЗаписи();
						запись.Период = ТекущаяДата();
						запись.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
						запись.Характеристика = ВыборкаДетальныеЗаписи.Характеристика;
						
						запись.Статус = Перечисления.гф_СтатусыGTIN_В_НК.GTINПолучен;
						запись.GTIN = ВыборкаДетальныеЗаписи.Штрихкод;
						Запись.Организация = Организация;
						запись.Записать();

					КонецЕсли;	
					
				ИначеЕсли ВыборкаДетальныеЗаписи.Штрихкод = NULL Тогда
					СтруктураПоиска = Новый Структура("ВидНоменклатуры", ВыборкаДетальныеЗаписи.ВидНоменклатуры);
					СтрокиПоиска = СоответствияНоменклатурныхГруппТоварнымГруппам.НайтиСтроки(СтруктураПоиска);
					
					Если СтрокиПоиска.Количество()>0 
						И НЕ СтрокиПоиска[0].ЕстьGTIN Тогда
						
						ТекстОшибки = "";
						СвойстваПервогоСлояЗаполнены = гф_ИнтеграцияСервер.ПроверитьСвойствПервогоВторогоСлоя(ВыборкаДетальныеЗаписи.Номенклатура, ВыборкаДетальныеЗаписи.Характеристика,,ТекстОшибки);
						Если СвойстваПервогоСлояЗаполнены Тогда

							запись = РегистрыСведений.гф_СтатусыGTIN.СоздатьМенеджерЗаписи();
							запись.Период = ТекущаяДата();
							запись.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
							запись.Характеристика = ВыборкаДетальныеЗаписи.Характеристика;
							
							запись.Статус = Перечисления.гф_СтатусыGTIN_В_НК.КПолучениюGTIN;
							запись.GTIN = ВыборкаДетальныеЗаписи.Штрихкод;
							Запись.Организация = Организация;
							запись.Записать();
							
						КонецЕсли;	

					КонецЕсли;
				КонецЕсли;	
			КонецЕсли;	
		КонецЦикла;
		
		//++ ЕсиповАВ 05.06.2023
		КонецЕсли;
		//--ЕсиповАВ 05.06.2023
		
	КонецЕсли;	
	
КонецПроцедуры

&Перед("ПередЗаписью")
Процедура ИК_ПередЗаписью(Отказ)
	Если ЭтоНовый() Тогда
		ДополнительныеСвойства.Вставить("ЭтоНовый", Истина);
	КонецЕсли;	
КонецПроцедуры
