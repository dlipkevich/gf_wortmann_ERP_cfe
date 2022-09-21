﻿ 
#Область ОбработчикиСобытий

&После("ОбработкаПроведения")
Процедура гф_ОбработкаПроведения(Отказ, РежимПроведения)
	
	Если Не Отказ И ЗначениеЗаполнено(Ссылка.гф_Заказ) Тогда
		гф_ДобавитьУпаковочныйЛистВЗаказКлиента();
	КонецЕсли;	
	
КонецПроцедуры

&Перед("ПередЗаписью")
Процедура гф_ПередЗаписью1(Отказ, РежимЗаписи, РежимПроведения)
	
	// #wortmann {
	// Галфинд Sakovich 2022/09/18
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	Если Не Отказ И  РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		гф_ПодготовитьАгрегациюКМ(Отказ);
	КонецЕсли;
	// } #wortmann
	
КонецПроцедуры

&После("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если Не Отказ И РежимЗаписи = РежимЗаписиДокумента.ОтменаПроведения 
		  И ЗначениеЗаполнено(Ссылка.гф_Заказ) Тогда
		 гф_УдалитьУпаковочныйЛистИзЗаказаКлиента();
	КонецЕсли;	
		
КонецПроцедуры 

// #wortmann {
// Галфинд Sakovich 2022/09/09
&Перед("ОбработкаПроверкиЗаполнения")
Процедура гф_ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	Если Не ЗначениеЗаполнено(гф_Поставка) Тогда
		Текст = "Не заполнено поле ""Поставка""";
		ОбщегоНазначения.СообщитьПользователю(Текст, Ссылка, , "Объект.гф_Поставка", Отказ);
	КонецЕсли;
КонецПроцедуры // } #wortmann

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура гф_ПодготовитьАгрегациюКМ(Отказ)
	
	Если Не ЗначениеЗаполнено(гф_Агрегация) Тогда
		Запрос = Новый Запрос("ВЫБРАТЬ
		|	ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод КАК Штрихкод
		|ПОМЕСТИТЬ ЗанятыеКМ
		|ИЗ
		|	Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ШтрихкодыУпаковокТоваровВложенныеШтрихкоды
		|ГДЕ
		|	ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Штрихкод.ТипУпаковки = &ТипУпаковкиМаркированныйТовар
		|	И НЕ ШтрихкодыУпаковокТоваровВложенныеШтрихкоды.Ссылка.ЗначениеШтрихкода = &КодУпаковочногоЛиста
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Штрихкод
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ШтрихкодыУпаковокТоваров.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
		|ГДЕ
		|	ШтрихкодыУпаковокТоваров.ТипУпаковки = &ТипУпаковкиМультитоварная
		|	И ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода = &КодУпаковочногоЛиста
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	УпаковочныйЛистТовары.Номенклатура КАК Номенклатура,
		|	УпаковочныйЛистТовары.Характеристика КАК Характеристика,
		|	УпаковочныйЛистТовары.Количество КАК Количество,
		|	УпаковочныйЛистТовары.Ссылка КАК УпЛист,
		|	ШтрихкодыУпаковокТоваров.Ссылка КАК КМ,
		|	ШтрихкодыУпаковокТоваров.ТипУпаковки КАК ТипУпаковки,
		|	ШтрихкодыУпаковокТоваров.ТипШтрихкода КАК ТипШтрихкода,
		|	ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода КАК ЗначениеШтрихкода
		|ИЗ
		|	Документ.УпаковочныйЛист.Товары КАК УпаковочныйЛистТовары
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
		|		ПО (УпаковочныйЛистТовары.Номенклатура = ШтрихкодыУпаковокТоваров.Номенклатура)
		|			И (УпаковочныйЛистТовары.Характеристика = ШтрихкодыУпаковокТоваров.Характеристика)
		|ГДЕ
		|	ШтрихкодыУпаковокТоваров.ТипУпаковки = &ТипУпаковкиМаркированныйТовар
		|	И НЕ ШтрихкодыУпаковокТоваров.Ссылка В
		|				(ВЫБРАТЬ
		|					т.Штрихкод
		|				ИЗ
		|					ЗанятыеКМ КАК т)
		|	И УпаковочныйЛистТовары.Ссылка = &УпаковочныйЛист
		|ИТОГИ ПО
		|	Номенклатура,
		|	Характеристика,
		|	Количество");
		
		Запрос.УстановитьПараметр("ТипУпаковкиМультитоварная", Перечисления.ТипыУпаковок.МультитоварнаяУпаковка);
		Запрос.УстановитьПараметр("ТипУпаковкиМаркированныйТовар", Перечисления.ТипыУпаковок.МаркированныйТовар);
		Запрос.УстановитьПараметр("КодУпаковочногоЛиста", Код);
		Запрос.УстановитьПараметр("УпаковочныйЛист", Ссылка);
		ПакетРезультатов = Запрос.ВыполнитьПакет();
		
		Если ПакетРезультатов[1].Пустой() Тогда
			ОбъектШтрихкод = Справочники.ШтрихкодыУпаковокТоваров.СоздатьЭлемент();	
			ОбъектШтрихкод.ТипУпаковки = Перечисления.ТипыУпаковок.МультитоварнаяУпаковка;
			ОбъектШтрихкод.ТипШтрихкода = Перечисления.ТипыШтрихкодов.GS1_128;
			ОбъектШтрихкод.ЗначениеШтрихкода = Код;
			ОбъектШтрихкод.гф_АртикулАгрегата = гф_Комплектация;
		Иначе
			Выборка = ПакетРезультатов[1].Выбрать();
			Выборка.Следующий();
			ОбъектШтрихкод = Выборка.Ссылка.ПолучитьОбъект();
			Если Не ЗначениеЗаполнено(ОбъектШтрихкод.гф_АртикулАгрегата) Тогда
				ОбъектШтрихкод.гф_АртикулАгрегата = гф_Комплектация;
			КонецЕсли;
		КонецЕсли;
		
		ОбъектШтрихкод.ВложенныеШтрихкоды.Очистить();
		ВыборкаНоменклатура = ПакетРезультатов[2].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаНоменклатура.Следующий() Цикл
			ВыборкаХарактеристика = ВыборкаНоменклатура.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаХарактеристика.Следующий() Цикл
				ВыборкаКоличество = ВыборкаХарактеристика.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				Пока ВыборкаКоличество.Следующий() Цикл
					КоличествоКМ = ВыборкаКоличество.Количество;
					ВыборкаДетали = ВыборкаКоличество.Выбрать();
					Для Сч = 1 По КоличествоКМ Цикл
						Если ВыборкаДетали.Следующий() Тогда
							нс = ОбъектШтрихкод.ВложенныеШтрихкоды.Добавить();
							нс.Штрихкод = ВыборкаДетали.КМ;
						Иначе
							Прервать;
						КонецЕсли;
					КонецЦикла;
				КонецЦикла;
			КонецЦикла;
		КонецЦикла;
		КоличествоВложенныхШтрихкодов = ОбъектШтрихкод.ВложенныеШтрихкоды.Количество();
		ОбъектШтрихкод.Количество = КоличествоВложенныхШтрихкодов;
		Если КоличествоВложенныхШтрихкодов = Товары.Итог("КоличествоУпаковок") Тогда
			ОбъектШтрихкод.Записать();
			гф_Агрегация = ОбъектШтрихкод.Ссылка;
		Иначе
			ТекстСообщения = 
			"При создании агрегата Штрихкодов упаковок товаров не "
			+ "найдено достаточного количества кодов маркировки 
			|Документ ""Упаковочный лист"" не может быть проведен.";
			ОбщегоНазначения.СообщитьПользователю(ТекстСообщения, , , ,Отказ);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура гф_ДобавитьУпаковочныйЛистВЗаказКлиента()
	
	Запрос = новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации КАК ВариантКомплектации,
	|	ЗаказКлиентагф_ТоварыВКоробах.ИдентификаторСтроки КАК ИдентификаторСтроки,
	|	ЗаказКлиентагф_ТоварыВКоробах.Ссылка КАК ЗаказКлиента
	|ИЗ
	|	Документ.ЗаказКлиента.гф_ТоварыВКоробах КАК ЗаказКлиентагф_ТоварыВКоробах
	|ГДЕ
	|	ЗаказКлиентагф_ТоварыВКоробах.Ссылка = &ЗаказКлиента
	|	И ЗаказКлиентагф_ТоварыВКоробах.ВариантКомплектации = &ВариантКомплектации";
	
	Запрос.УстановитьПараметр("ЗаказКлиента", Ссылка.гф_Заказ);
	Запрос.УстановитьПараметр("ВариантКомплектации", Ссылка.гф_Комплектация);
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	Для каждого Строка из Результат Цикл
		
		ЗаказКлиентаОбъект = Строка.ЗаказКлиента.ПолучитьОбъект();
		
		Отбор = Новый Структура;
		Отбор.Вставить("ИдентификаторСтроки", Строка.ИдентификаторСтроки);
		Отбор.Вставить("УпаковочныйЛист", Ссылка);
		
		НайденныеСтроки = ЗаказКлиентаОбъект.гф_УпаковочныеЛисты.НайтиСтроки(Отбор);
		
		Если НайденныеСтроки.Количество() <> 0 Тогда
			 Продолжить;
		КонецЕсли;	
		
		НоваяСтрока = ЗаказКлиентаОбъект.гф_УпаковочныеЛисты.Добавить();
		НоваяСтрока.ИдентификаторСтроки = Строка.ИдентификаторСтроки;
		НоваяСтрока.УпаковочныйЛист = Ссылка;
				
		ЗаказКлиентаОбъект.ОбменДанными.Загрузка = Истина;
		ЗаказКлиентаОбъект.Записать();
	КонецЦикла;

КонецПроцедуры	

Процедура гф_УдалитьУпаковочныйЛистИзЗаказаКлиента()
	
	ЗаказКлиентаОбъект = Ссылка.гф_Заказ.ПолучитьОбъект();
	
	Отбор = Новый Структура;
	Отбор.Вставить("УпаковочныйЛист", Ссылка);
	
	НайденныеСтроки = ЗаказКлиентаОбъект.гф_УпаковочныеЛисты.НайтиСтроки(Отбор);
    
	Для каждого Строка из НайденныеСтроки Цикл
		ЗаказКлиентаОбъект.гф_УпаковочныеЛисты.Удалить(Строка);
	КонецЦикла;
	
	Если НайденныеСтроки.Количество() <> 0 Тогда
		ЗаказКлиентаОбъект.ОбменДанными.Загрузка = Истина;
		ЗаказКлиентаОбъект.Записать();              
	КонецЕсли;
	
КонецПроцедуры;

#КонецОбласти
