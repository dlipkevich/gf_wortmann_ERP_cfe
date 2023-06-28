﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

&ИзменениеИКонтроль("ПодготовитьСтруктуруДанных")
Функция гф_ПодготовитьСтруктуруДанных(СтруктураНастроек)
	
	СтруктураРезультата = Новый Структура;
	СтруктураРезультата.Вставить("ТаблицаТоваров",                             Неопределено);
	СтруктураРезультата.Вставить("СоответствиеПолейСКДКолонкамТаблицыТоваров", Новый Соответствие);

#Область ПодготовкаСхемыКомпоновкиДанныхИКомпоновщикаНастроекСкд
	
	// Схема компоновки.
	СхемаКомпоновкиДанных = Обработки.ПодборТоваровПоОтбору.ПолучитьМакет(СтруктураНастроек.ИмяМакетаСхемыКомпоновкиДанных);
    #Вставка
	// #wortmann { 
	// Внесение изменений для ограничения чтения с производительным RLS
	// Галфинд_Домнышева 2022/11/18
	Если СтруктураНастроек.ИмяМакетаСхемыКомпоновкиДанных = "Макет2_5" Тогда
		ТекстЗапроса = СхемаКомпоновкиДанных.НаборыДанных.НаборДанных.Запрос;
		
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса,
			(Символы.ПС + "ВЫБРАТЬ" + Символы.ПС + Символы.Таб
			+ "ВидыНоменклатуры.ВидНоменклатуры КАК ВидНоменклатуры," + Символы.ПС + Символы.Таб + "Номенклатура.Ссылка"), 
			(Символы.ПС + "ВЫБРАТЬ РАЗРЕШЕННЫЕ" + Символы.ПС + Символы.Таб
			+ "ВидыНоменклатуры.ВидНоменклатуры КАК ВидНоменклатуры," + Символы.ПС + Символы.Таб + "Номенклатура.Ссылка"));
		
		СхемаКомпоновкиДанных.НаборыДанных.НаборДанных.Запрос = ТекстЗапроса;
	КонецЕсли;
	// } #wortmann
	#КонецВставки

	ИнтеграцияСМаркетплейсамиСерверЛокализация.ДополнитьСКДДляМаркетплейсов(СтруктураНастроек, СхемаКомпоновкиДанных);

	// Подготовка компоновщика макета компоновки данных.
	Компоновщик = Новый КомпоновщикНастроекКомпоновкиДанных;
	Компоновщик.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаКомпоновкиДанных));
	Компоновщик.ЗагрузитьНастройки(СхемаКомпоновкиДанных.НастройкиПоУмолчанию);
	Компоновщик.Настройки.Отбор.Элементы.Очистить();
	Компоновщик.Восстановить(СпособВосстановленияНастроекКомпоновкиДанных.Полное);
	
	// Отбор и сортировка компоновщика настроек.
	Если СтруктураНастроек.КомпоновщикНастроек <> Неопределено Тогда
		
		КомпоновкаДанныхКлиентСервер.СкопироватьЭлементы(
			Компоновщик.Настройки.Отбор,
			СтруктураНастроек.КомпоновщикНастроек.Настройки.Отбор);
			
		КомпоновкаДанныхКлиентСервер.СкопироватьЭлементы(
			Компоновщик.Настройки.Порядок,
			СтруктураНастроек.КомпоновщикНастроек.Настройки.Порядок);
			
	КонецЕсли;

	ИнтеграцияСМаркетплейсамиСерверЛокализация.ЗаполнитьУчетнуюЗапись(СтруктураНастроек, Компоновщик);

	ИспользоватьАссортимент = ПолучитьФункциональнуюОпцию("ИспользоватьАссортимент");
	Если ИспользоватьАссортимент Тогда
		КомпоновкаДанныхКлиентСервер.УстановитьПараметр(Компоновщик.Настройки, "АссортиментНаДату", ТекущаяДатаСеанса());
	КонецЕсли;
	
	Если СтруктураНастроек.Свойство("ЦеныНаДату") Тогда
		КомпоновкаДанныхКлиентСервер.УстановитьПараметр(Компоновщик.Настройки, "ЦеныНаДату", СтруктураНастроек.ЦеныНаДату);
	КонецЕсли;
	
	Если СтруктураНастроек.Свойство("Поставщик") Тогда
		КомпоновкаДанныхКлиентСервер.УстановитьПараметр(Компоновщик.Настройки, "Поставщик", СтруктураНастроек.Поставщик);
	КонецЕсли;
	
	Если СтруктураНастроек.Свойство("ОтборПоВариантуРасчетаЦенНаборов") Тогда
		ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(
			Компоновщик.Настройки.Отбор,
			"ВариантРасчетаЦеныНабора",
			ВидСравненияКомпоновкиДанных.ВСписке,
			СтруктураНастроек.ОтборПоВариантуРасчетаЦенНаборов,
			Неопределено,
			Истина,
			РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ);
	КонецЕсли;
	
	Если СтруктураНастроек.ВестиУчетСертификатовНоменклатуры Тогда
		КомпоновкаДанныхКлиентСервер.УстановитьПараметр(Компоновщик.Настройки, "ВестиУчетСертификатовНоменклатуры", Истина);
	КонецЕсли;
	
	Если СтруктураНастроек.Свойство("ИспользуетсяОтборПоВнешнемуИсточникуДанных") Тогда
		
		ВнешниеНаборыДанных = Неопределено;
		
		Если СтруктураНастроек.Свойство("ТаблицаТоваров") Тогда
			КолонкиТаблицыТоваров = СтруктураНастроек.ТаблицаТоваров.Колонки;
			МассивКолонок = Новый Массив();

			Если Не КолонкиТаблицыТоваров.Найти("ВидЦены") = Неопределено Тогда
				МассивКолонок.Добавить("ВидЦены");
			КонецЕсли;
		
			Если Не КолонкиТаблицыТоваров.Найти("Цена") = Неопределено Тогда
				МассивКолонок.Добавить("Цена");
			КонецЕсли;

			НастроитьНаборыДанных(СхемаКомпоновкиДанных, КолонкиТаблицыТоваров);

			ДопИменаКолонок = СтрСоединить(МассивКолонок, ", ");
			Если ЗначениеЗаполнено(ДопИменаКолонок) Тогда
				ДопИменаКолонок = ", " + ДопИменаКолонок;
			КонецЕсли;
			
			ВнешниеНаборыДанных = Новый Структура;
			ТаблицаДляИсточника = СтруктураНастроек.ТаблицаТоваров.Скопировать(, "Номенклатура, Характеристика, Серия, Упаковка" + ДопИменаКолонок);// ТаблицаЗначений
			ТаблицаДляИсточника.Свернуть("Номенклатура, Характеристика, Серия, Упаковка" + ДопИменаКолонок);
			
				
			ПоСерии = Ложь;
			ПоУпаковке = Ложь;
			
			Если КолонкиТаблицыТоваров.Найти("Серия") <> Неопределено Тогда
				ПоСерии = Истина;
				ТаблицаДляИсточника.Колонки.Добавить("СерияДляСвязи", Новый ОписаниеТипов("СправочникСсылка.СерииНоменклатуры"));
			КонецЕсли;

			Если КолонкиТаблицыТоваров.Найти("Упаковка") <> Неопределено Тогда
				ПоУпаковке = Истина;
				ТаблицаДляИсточника.Колонки.Добавить("УпаковкаДляСвязи", Новый ОписаниеТипов("СправочникСсылка.УпаковкиЕдиницыИзмерения"));
			КонецЕсли;
			
			ТаблицаДляОтбора = ТаблицаДляИсточника.Скопировать(, "Номенклатура");
			ТаблицаДляОтбора.Свернуть("Номенклатура");
			СписокДляОтбора = ТаблицаДляОтбора.ВыгрузитьКолонку("Номенклатура");
			
			Если ПоСерии Или ПоУпаковке Тогда
				ТаблицаНастроекЦенообразования = ПолучитьТаблицуНастроекЦенообразования(СписокДляОтбора);
				Для Каждого Настройка Из ТаблицаНастроекЦенообразования Цикл
					НайденныеСтроки = ТаблицаДляИсточника.НайтиСтроки(Новый Структура("Номенклатура", Настройка.Номенклатура));
					
					Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
						Если ПоСерии И Настройка.ПоСерии Тогда
							НайденнаяСтрока.СерияДляСвязи = НайденнаяСтрока.Серия;
						КонецЕсли;
						Если ПоУпаковке И Настройка.ПоУпаковке Тогда
							НайденнаяСтрока.УпаковкаДляСвязи = НайденнаяСтрока.Упаковка;
						КонецЕсли;
					КонецЦикла;
				КонецЦикла;
			КонецЕсли;
			
			ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(
				Компоновщик.Настройки.Отбор,
				"Номенклатура",
				ВидСравненияКомпоновкиДанных.ВСписке,
				СписокдляОтбора,
				Неопределено,
				Истина);
				
			ВнешниеНаборыДанных.Вставить("ТаблицаНоменклатуры", ТаблицаДляИсточника);
			
		КонецЕсли;
	КонецЕсли;
	
	// Выбранные поля компоновщика настроек.
	Для Каждого ОбязательноеПоле Из СтруктураНастроек.ОбязательныеПоля Цикл
		ПолеСКД = КомпоновкаДанныхСервер.НайтиПолеСКДПоПолномуИмени(Компоновщик.Настройки.Выбор.ДоступныеПоляВыбора.Элементы, ОбязательноеПоле);
		Если ПолеСКД <> Неопределено Тогда
			ВыбранноеПоле = Компоновщик.Настройки.Выбор.Элементы.Добавить(Тип("ВыбранноеПолеКомпоновкиДанных"));
			ВыбранноеПоле.Поле = ПолеСКД.Поле;
		КонецЕсли;
	КонецЦикла;
	
	СегментыСервер.ВключитьОтборПоСегментуНоменклатурыВСКД(Компоновщик);

	// Компоновка макета компоновки данных.
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновкиДанных = КомпоновщикМакета.Выполнить(
		СхемаКомпоновкиДанных,
		Компоновщик.ПолучитьНастройки(),,,
		Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));

#КонецОбласти

#Область ПодготовкаВспомогательныхДанныхДляСопоставленияПолейШаблонаИСкд
	
	Для каждого Поле Из МакетКомпоновкиДанных.НаборыДанных.НаборДанных.Поля Цикл
		СтруктураРезультата.СоответствиеПолейСКДКолонкамТаблицыТоваров.Вставить(
			Справочники.ШаблоныЭтикетокИЦенников.ИмяПоляВШаблоне(Поле.ПутьКДанным), Поле.Имя);
	КонецЦикла;

#КонецОбласти

#Область ПодготовкаТаблицыТоваров
	
	ТаблицаТоваров = Новый ТаблицаЗначений;
	
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	Если ВнешниеНаборыДанных = Неопределено Тогда
		ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновкиДанных);
	Иначе
		ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновкиДанных, ВнешниеНаборыДанных);
	КонецЕсли;
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.УстановитьОбъект(ТаблицаТоваров);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных);
	
	СтруктураРезультата.ТаблицаТоваров = ТаблицаТоваров;
	
	Возврат СтруктураРезультата;
	
#КонецОбласти

КонецФункции

#КонецОбласти

#КонецЕсли