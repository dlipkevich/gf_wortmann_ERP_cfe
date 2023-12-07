﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	// #wortmann {
	// #учет Кодов Маркиовки (КМ)
	// Галфинд Sakovich 2022/11/01
	ОписаниеТиповБулево = Новый ОписаниеТипов("Булево");
	ДобавляемыеРеквизиты = Новый Массив;
	НовыйРеквизит = Новый РеквизитФормы("гф_ЗаполнятьШтрихкодыУпаковок", ОписаниеТиповБулево);
	ДобавляемыеРеквизиты.Добавить(НовыйРеквизит);
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	// } #wortmann
	
	// #wortmann {
	// #отгрузка по заказам
	// Галфинд Волков 2023/12/07
	Если Объект.СкладскаяОперация = Перечисления.СкладскиеОперации.ОтгрузкаКлиенту Тогда
		
		ОписаниеТиповБулево 	= Новый ОписаниеТипов("ДокументСсылка.РеализацияТоваровУслуг");
		ДобавляемыеРеквизиты 	= Новый Массив;
		НовыйРеквизит 			= Новый РеквизитФормы("гф_РеализацияТоваровУслуг",
											ОписаниеТиповБулево, , "Реализация товаров и услуг", Истина);
		ДобавляемыеРеквизиты.Добавить(НовыйРеквизит);
		ИзменитьРеквизиты(ДобавляемыеРеквизиты);
		
		ТипПолеФормы = Тип("ПолеФормы");
		
		НовоеПоле = Элементы.Добавить("гф_РеализацияТоваровУслуг", ТипПолеФормы, Элементы.ГруппаИнформацияПраво);
		
		НовоеПоле.Вид				= ВидПоляФормы.ПолеВвода;
		НовоеПоле.Видимость			= Истина;
		НовоеПоле.ТолькоПросмотр 	= Истина;
		НовоеПоле.ПутьКДанным		= "гф_РеализацияТоваровУслуг";
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	РеализацияТоваровУслуг.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
		|ГДЕ
		|	РеализацияТоваровУслуг.гф_РасходныйОрдер = &Ссылка";
		
		Запрос.УстановитьПараметр("Ссылка", Объект.Ссылка);
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			ЭтотОбъект.гф_РеализацияТоваровУслуг = ВыборкаДетальныеЗаписи.Ссылка;
			Прервать;
		КонецЦикла;
		
	КонецЕсли;
	// } #wortmann
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура гф_ПровестиИЗакрытьВместо(Команда)
	
	// #wortmann {
	// #учет Кодов Маркировки (КМ)
	// Галфинд Sakovich 2022/11/01
	НужноЗаполнятьШтрихкодыУпаковок =  ПроверитьСтатусыКонтроляИСклад(Объект.Статус, Объект.Склад);
	Если НужноЗаполнятьШтрихкодыУпаковок Тогда
		Если Объект.ШтрихкодыУпаковок.Количество() = 0 Тогда
			ЗадатьВопросОЗаполненииШтрихкодовУпаковок(Команда);
		Иначе
			ЭтотОбъект.гф_ЗаполнятьШтрихкодыУпаковок = Истина;
			ЗаполнитьШтрихкодыУпаковок();
			ПродолжитьВызов(Команда);
		КонецЕсли;
	Иначе
		ПродолжитьВызов(Команда);
	КонецЕсли;
	// } #wortmann

КонецПроцедуры

&НаКлиенте
Процедура гф_ПровестиДокументВместо(Команда)
	
	// #wortmann {
	// #учет Кодов Маркировки (КМ)
	// Галфинд Sakovich 2022/11/01
	НужноЗаполнятьШтрихкодыУпаковок =  ПроверитьСтатусыКонтроляИСклад(Объект.Статус, Объект.Склад);
	Если НужноЗаполнятьШтрихкодыУпаковок Тогда
		Если Объект.ШтрихкодыУпаковок.Количество() = 0 Тогда
			ЗадатьВопросОЗаполненииШтрихкодовУпаковок(Команда);
		Иначе
			ЭтотОбъект.гф_ЗаполнятьШтрихкодыУпаковок = Истина;
			ЗаполнитьШтрихкодыУпаковок();
			ПродолжитьВызов(Команда);
		КонецЕсли;
	Иначе
		ПродолжитьВызов(Команда);
	КонецЕсли;
	// } #wortmann

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗадатьВопросОЗаполненииШтрихкодовУпаковок(Команда)

	ТекстВопроса = НСтр("ru='Табличная часть ""Штрихкоды упаковок"" пустая. Будет выполнена "
	+ "попытка заполнения. Продолжить?'");
	ДопПараметры = Новый Структура("Команда", Команда);
	Оповещение = Новый ОписаниеОповещения("гф_ВопросЗаполнитьШтрихкодыУпаковокЗавершение", ЭтотОбъект, ДопПараметры);
	ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьШтрихкодыУпаковок()

	// #wortmann {
	// #учет Кодов Маркировки (КМ)
	// Галфинд Sakovich 2022/11/01
	Если ЭтотОбъект.гф_ЗаполнятьШтрихкодыУпаковок Тогда
		Объект.ШтрихкодыУпаковок.Очистить();
		
		Запрос = Новый Запрос("ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	РасходныйОрдерНаТоварыОтгружаемыеТовары.УпаковочныйЛист КАК УпаковочныйЛист
		|ПОМЕСТИТЬ УпЛисты
		|ИЗ
		|	Документ.РасходныйОрдерНаТовары.ОтгружаемыеТовары КАК РасходныйОрдерНаТоварыОтгружаемыеТовары
		|ГДЕ
		|	РасходныйОрдерНаТоварыОтгружаемыеТовары.Ссылка = &Ссылка
		|	И РасходныйОрдерНаТоварыОтгружаемыеТовары.ЭтоУпаковочныйЛист
		|;
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ШтрихкодыУпаковокТоваров.Ссылка КАК ШтрихкодУпаковки
		|ИЗ
		|	УпЛисты КАК УпЛисты
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
		|		ПО (УпЛисты.УпаковочныйЛист.Код = ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода)
		|ГДЕ
		|	ШтрихкодыУпаковокТоваров.Ссылка ЕСТЬ НЕ NULL 
		|	И ШтрихкодыУпаковокТоваров.ТипУпаковки = ЗНАЧЕНИЕ(Перечисление.ТипыУпаковок.МультитоварнаяУпаковка)");
		Запрос.УстановитьПараметр("Ссылка", Объект.Ссылка);
		Результат = Запрос.Выполнить();
		
		Если Не Результат.Пустой() Тогда
			тзШтрихкоды = Результат.Выгрузить();
			Объект.ШтрихкодыУпаковок.Загрузить(тзШтрихкоды);
		КонецЕсли;
		
	КонецЕсли;
	// } #wortmann

КонецПроцедуры


&НаСервере
&ИзменениеИКонтроль("ПриЧтенииСозданииНаСервере")
Процедура гф_ПриЧтенииСозданииНаСервере()

	УстановитьПараметрыФункциональныхОпцийФормы(Новый Структура("Склад,Помещение",Объект.Склад,Объект.Помещение));

	ПараметрыУказанияСерий = Новый ФиксированнаяСтруктура(НоменклатураСервер.ПараметрыУказанияСерий(Объект, Документы.РасходныйОрдерНаТовары));

	НачинатьОтгрузкуПослеФормированияЗаданияНаПеревозку = ПолучитьФункциональнуюОпцию("НачинатьОтгрузкуПослеФормированияЗаданияНаПеревозку", Новый Структура("Склад", Объект.Склад));

	УстановитьЗависимыеОтАдресногоХранения();

	СобытияФорм.ПриЧтенииНаСервере(ЭтотОбъект, Объект);

	РасходныйОрдерНаТоварыЛокализация.УстановитьПризнакИспользованияМаркируемойПродукции(ЭтаФорма);
	#Вставка
	// #wortmann {
	// #Автоматическое заполнение табличной части документа Расходный ордер 
	// Номенклатура и упаковочный лист одновременно являются маркируемыми товарами, иначе в РасходномОрдере в ТЧ только номенклатура
	// Галфинд Volkov 2022/09/10
	Если ОбщегоНазначенияКлиентСервер.ЕстьРеквизитИлиСвойствоОбъекта(ЭтаФорма, "ЕстьМаркируемаяПродукция") Тогда
		
		ТЗ = Новый ТаблицаЗначений;
		ТЗ = Объект.ОтгружаемыеТовары.Выгрузить(,"ЭтоУпаковочныйЛист");
		
		УпаковочныйЛистНайден = ТЗ.Найти(Истина, "ЭтоУпаковочныйЛист");
		
		Если Не УпаковочныйЛистНайден = Неопределено И УпаковочныйЛистНайден.ЭтоУпаковочныйЛист Тогда
			ЭтаФорма.ИспользоватьУпаковочныеЛисты = Истина;
			ЭтаФорма.ЕстьМаркируемаяПродукция = Ложь;
		КонецЕсли;
		
	КонецЕсли;
	// } #wortmann
	#КонецВставки
	УстановитьВидимостьЭлементовУпаковкиПриМаркировке();

	УпаковочныеЛистыСервер.ПриЧтенииСозданииФормыСУпаковочнымиЛистами(ЭтаФорма, Объект.ОтгружаемыеТовары,
	Объект.Ссылка.Метаданные().ПредставлениеОбъекта);

	ЗаполнитьСлужебныеРеквизитыТЧТовары("ТоварыПоРаспоряжениям", Ложь);
	ЗаполнитьСлужебныеРеквизитыТЧТовары("ОтгружаемыеТовары", Ложь);

	Если Объект.ОтгрузкаПоЗаданиюНаПеревозку Тогда
		Элементы.ПорядокДоставки.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Авто;
		ТипОтгрузки = "ОтгрузкаПоЗаданиюНаПеревозку";
	Иначе
		Элементы.ПорядокДоставки.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Нет;
		ТипОтгрузки = "Самовывоз";
	КонецЕсли;

	Элементы.ГруппаИнформацияИКомментарий.Картинка = ОбщегоНазначенияКлиентСервер.КартинкаКомментария(Объект.Комментарий);
	УстановитьДоступность();

	ЕстьДоставкаПоСкладскойОперации       = ДоставкаТоваров.ЕстьДоставкаПоСкладскойОперации(Объект.СкладскаяОперация);

	Элементы.ТипОтгрузки.Видимость        = ЕстьДоставкаПоСкладскойОперации Или Объект.ОтгрузкаПоЗаданиюНаПеревозку;
	Элементы.ЗаданиеНаПеревозку.Видимость = ЕстьДоставкаПоСкладскойОперации Или Объект.ОтгрузкаПоЗаданиюНаПеревозку;
	Элементы.ПорядокДоставки.Видимость    = ЕстьДоставкаПоСкладскойОперации Или Объект.ОтгрузкаПоЗаданиюНаПеревозку;

	РаботаСТабличнымиЧастями.ИнициализироватьКэшСтрок(Элементы.ОтгружаемыеТовары);

КонецПроцедуры

&НаСервереБезКонтекста
Функция ПроверитьСтатусыКонтроляИСклад(Статус, Склад)
	
	ЭтоКонтролируемыйСтатус = Ложь;
	
	СтатусыКонтроля = Новый Массив;
	СтатусыКонтроля.Добавить(Перечисления.СтатусыРасходныхОрдеров.Проверен);
	СтатусыКонтроля.Добавить(Перечисления.СтатусыРасходныхОрдеров.КОтгрузке);
	СтатусыКонтроля.Добавить(Перечисления.СтатусыРасходныхОрдеров.Отгружен);
	
	Если СтатусыКонтроля.Найти(Статус) <> Неопределено Тогда
		ЭтоКонтролируемыйСтатус = Истина;
	КонецЕсли;
	
	ЭтоКоробочныйСклад = УправлениеСвойствами.ЗначениеСвойства(Склад, "гф_СкладыТоварыВКоробах") = Истина;
	
	Возврат ЭтоКонтролируемыйСтатус И ЭтоКоробочныйСклад;
	
КонецФункции

&НаКлиенте
Процедура гф_ВопросЗаполнитьШтрихкодыУпаковокЗавершение (Результат, ДополнительныеПараметры) Экспорт
	
	Команда = ДополнительныеПараметры["Команда"];
	гф_ЗаполнятьШтрихкодыУпаковок = Результат = КодВозвратаДиалога.Да;
	ЗаполнитьШтрихкодыУпаковок();

	Если Команда["Имя"] = "ПровестиДокумент" Тогда
		ОбщегоНазначенияУТКлиент.Провести(ЭтаФорма, Истина);
	КонецЕсли;
	
	Если Команда["Имя"] = "ПровестиИЗакрыть" Тогда
		ОбщегоНазначенияУТКлиент.ПровестиИЗакрыть(ЭтаФорма, Истина);
	КонецЕсли;

КонецПроцедуры	

#КонецОбласти