﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	// #wortmann {
	// #1.1. Регистрация возвратов
	// Галфинд Sakovich 2022/11/11
	гф_ДобавитьЭлементыФормы();
	ЭтотОбъект["СтруктураЗаказНаЭмиссиюКодовМаркировки"] = Новый Структура;
	// } #wortmann
КонецПроцедуры

&НаКлиенте
Процедура гф_ВозвращаемыеТоварыПриИзмененииПосле(Элемент)
	// #wortmann {
	// #1.1. Регистрация возвратов
	// Галфинд Sakovich 2022/11/11
	ПроверитьЗаполнитьКМСтрокой();
	// } #wortmann
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура гф_ЗагрузитьТоварыИзФайла(Команда)
	Если Объект.ВозвращаемыеТовары.Количество() > 0 Тогда
		ТекстВопроса = НСтр("ru='Табличная часть ""Возвращаемые товары"" уже содержит строки и будет очищена. Продолжить?'");
		ДопПараметры = Новый Структура() ;
		Оповещение = Новый ОписаниеОповещения("гф_ВопросЗагрузитьТоварыИзФайлаЗавершение", ЭтотОбъект, ДопПараметры);
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
	Иначе
		ЗагрузитьТоварыИзФайлаПо_ГТИН_КМ();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура гф_ВопросЗагрузитьТоварыИзФайлаЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = КодВозвратаДиалога.Да Тогда
		ЗагрузитьТоварыИзФайлаПо_ГТИН_КМ();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьТоварыИзФайлаПо_ГТИН_КМ()

	ПараметрыЗагрузки = ЗагрузкаДанныхИзФайлаКлиент.ПараметрыЗагрузкиДанных();
	ПараметрыЗагрузки.ПолноеИмяТабличнойЧасти = 
		"Документ.ЗаявкаНаВозвратТоваровОтКлиента.ТабличнаяЧасть.ВозвращаемыеТовары";
	ПараметрыЗагрузки.Заголовок = НСтр("ru = 'Загрузка списка товаров из файла'");
	ДополнительныеПараметры = Новый Структура();
	ДополнительныеПараметры.Вставить("Команда", "гф_ЗагрузитьТоварыИзФайла");
	ПараметрыЗагрузки.ДополнительныеПараметры = ДополнительныеПараметры;
	Оповещение = Новый ОписаниеОповещения("гф_ЗагрузитьТоварыИзФайлаЗавершение", ЭтотОбъект);
	ЗагрузкаДанныхИзФайлаКлиент.ПоказатьФормуЗагрузки(ПараметрыЗагрузки, Оповещение);

КонецПроцедуры

&НаКлиенте
Процедура гф_ПроверитьКМ(Команда)
	
	// 1. установка служебного Назначения «Холд (временно)»
	ПустоеНазначение = ПредопределенноеЗначение("Справочник.Назначения.ПустаяСсылка");
	
	НазначениеХолд = _омОбщегоНазначенияВызовСервера.ПолучитьГлобальноеЗначение(
	"СлужебноеНазначениеВозвратТоваров", 	ПустоеНазначение, Истина);
	Если Не ЗначениеЗаполнено(НазначениеХолд) Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
		"Не найдено глобальное значение с ключом ""СлужебноеНазначениеВозвратТоваров""!");
	КонецЕсли;
	Для каждого стрТч Из Объект.ВозвращаемыеТовары Цикл
		стрТч["Назначение"] = НазначениеХолд;
		стрТч["гф_ПроизведенаПроверкаКМ"] = Ложь;
		стрТч["гф_СтатусПроверкиКМ"] = "";
		стрТч["гф_КлиентЯвляетсяВладельцемКМ"] = Ложь;
	КонецЦикла;
	
	// 2. проверка статусов и владельца принятых кодов   маркировки через ИС МП
	ИННВладельца = ОбщегоНазначенияУТВызовСервера.ЗначениеРеквизитаОбъекта(Объект.Контрагент, "ИНН");
	ИННВладельцаПустой = СокрЛП(ИННВладельца) = "";
	
	Если ИННВладельцаПустой Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю("Не заполнен ИНН клиента. Невозможно проверить владельца КМ!");
		Возврат;
	КонецЕсли;
	
	ПараметрыОткрытия = Новый Структура;
	МассивСтруктурШтрихкодовДляПроверки = ПолучитьМассивШтрихкодов();	// массив структур
	ШтрихкодыДляПроверки = Новый Массив;
	Для каждого элМассива Из МассивСтруктурШтрихкодовДляПроверки Цикл
		ШтрихкодыДляПроверки.Добавить(элМассива["Штрихкод"]);
	КонецЦикла;
	ПараметрыОткрытия.Вставить("Организация", Объект.Организация);
	ПараметрыОткрытия.Вставить("Штрихкоды", ШтрихкодыДляПроверки);
	ОповещениеОЗакрытии = Новый ОписаниеОповещения("ФормаПроверкиШтрихкодовПриЗакрытии", ЭтотОбъект);
	ФормаПроверки = ОткрытьФорму("Обработка.ПроверкаКодовМаркировкиИСМП.Форма.ФормаПроверки", 
	ПараметрыОткрытия, ЭтотОбъект, , , , ОповещениеОЗакрытии);
	
	// другой способ инициации проверки штрихкодов: (в этом случае в отрываемую форму обработки проверки 
	// НЕ нужно передавать в параметрах открытия  параметр "Штрихкоды")
	// см. процедуру гф_ОбработкаОповещенияПосле в модуле формы проверки
	//Оповестить("гф_ЗаявкаНаВозвратПроверкаКМ", МассивСтруктурШтрихкодовДляПроверки, ЭтотОбъект);
	
	// данные проверки необходимо сформировать до закрытия формы проверки
	ДанныеПроверки = Новый Структура();
	ДанныеПроверки.Вставить("ДеревоКодовМаркировки", ФормаПроверки.ДеревоКодовМаркировки);
	Если ЭтоАдресВременногоХранилища(
		ФормаПроверки.КэшМаркируемойПродукции) Тогда
	ДанныеКэша = ПолучитьИзВременногоХранилища(ФормаПроверки.КэшМаркируемойПродукции);
		ДанныеПроверки.Вставить("КэшМаркируемойПродукции", ДанныеКэша); 
	Иначе
		ДанныеПроверки.Вставить("КэшМаркируемойПродукции", Неопределено); 
	КонецЕсли;
	ДанныеПроверки.Вставить("ЗагрузкаДанныхТСД", ФормаПроверки.ЗагрузкаДанныхТСД);
	
	Если ФормаПроверки.Открыта() Тогда
		ФормаПроверки.Закрыть(ДанныеПроверки);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ФормаПроверкиШтрихкодовПриЗакрытии(Результат, ДополнительныеПараметры) Экспорт
	ПроверитьКМНаСервере(Результат, ДополнительныеПараметры);
	
	Для каждого элКоллекции Из Объект.ВозвращаемыеТовары Цикл
	
		Идентификатор = ЭлКоллекции.ПолучитьИдентификатор();
		Элементы.ВозвращаемыеТовары.ТекущаяСтрока = Идентификатор;
		ВозвращаемыеТоварыЦенаПриИзменении(Элементы["ВозвращаемыеТоварыЦена"]);
		ВозвращаемыеТоварыДокументРеализацииПриИзменении(Элементы["ВозвращаемыеТоварыДокументРеализации"]);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьКМНаСервере(Результат, ДополнительныеПараметры)
	
	ДеревоКодовМаркировки = Результат["ДеревоКодовМаркировки"]; // ДанныеФормыДерево
	ЗагрузкаДанныхТСД = Результат["ЗагрузкаДанныхТСД"];
	КэшМаркируемойПродукции = Результат["КэшМаркируемойПродукции"]; // структура
	
	ИННВладельца = ОбщегоНазначенияУТВызовСервера.ЗначениеРеквизитаОбъекта(Объект.Контрагент, "ИНН");
	ИННВладельцаПустой = СокрЛП(ИННВладельца) = "";
	
	ЭлементыДерева = ДеревоКодовМаркировки.ПолучитьЭлементы();
	Для каждого ЭлДерева Из ЭлементыДерева Цикл
		ПараметрыОтбора = Новый Структура("гф_КМСтрокой", ЭлДерева["Штрихкод"]);
		ЭлементыВозвращаемыеТовары = Объект.ВозвращаемыеТовары.НайтиСтроки(ПараметрыОтбора);
		Для каждого ЭлементТч Из ЭлементыВозвращаемыеТовары Цикл
			ЭлементТч["гф_ПроизведенаПроверкаКМ"] = Истина;
			ЭлементТч["гф_СтатусПроверкиКМ"] = ЭлДерева["Статус"];
			Если ИННВладельца  = ЭлДерева["ИННВладельца"]
				И Не ИННВладельцаПустой Тогда
				ЭлементТч["гф_КлиентЯвляетсяВладельцемКМ"] = Истина;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	// 3. заполнение в ТЧ «Товары» реквизитов «Документ продажи», «Цена», «Сумма»
	// из документа продажи для сопоставленных кодов маркировки
	// (Документ продажи устанавливается из записи РН «Движение кодов маркировки организации».
	// В случае возврата товара с кодами маркировки, которые не передавались клиенту,
	// но владельцем которых он является, устанавливается документ последней продажи клиенту товара с этим GTIN.
	ТекстЗапроса = ТекстЗапросаДокументыПродажи();
	табДанные = Объект.ВозвращаемыеТовары.Выгрузить();
	Запрос = Новый Запрос(ТекстЗапроса);
	Запрос.УстановитьПараметр("табДанные", табДанные);
	Запрос.УстановитьПараметр("КонецПериода", Объект.Дата);
	Запрос.УстановитьПараметр("Клиент", Объект.Контрагент);
	ПакетРезультатов = Запрос.ВыполнитьПакетСПромежуточнымиДанными();
	ВыборкаДанные = ПакетРезультатов[3].Выбрать();
	ВыборкаНеПереданные = ПакетРезультатов[4].Выбрать();
	МассивКМДляЗаписи = Новый Массив;
	Для каждого стрТч Из Объект.ВозвращаемыеТовары Цикл
		ВыборкаДанные.Сбросить();
		ВыборкаНеПереданные.Сбросить();
		СтруктураОтбора = Новый Структура("НомерСтроки, КМСтрокой", стрТч["НомерСтроки"], стрТч["гф_КМСтрокой"]);
		Если ВыборкаДанные.НайтиСледующий(СтруктураОтбора) Тогда
			Если ЗначениеЗаполнено(ВыборкаДанные["ДокументРеализации"]) Тогда
				ЗаполнитьЗначенияСвойств(стрТч, ВыборкаДанные, "ДокументРеализации, Цена, СтавкаНДС, Количество, КоличествоУпаковок");
			КонецЕсли;
		КонецЕсли;
		Если ВыборкаНеПереданные.НайтиСледующий(СтруктураОтбора) Тогда
			Если стрТч["гф_КлиентЯвляетсяВладельцемКМ"] Тогда
				ЗаполнитьЗначенияСвойств(стрТч, ВыборкаНеПереданные, "ДокументРеализации, Цена, СтавкаНДС, Количество, КоличествоУпаковок");
				СтруктураЗаписи = Новый Структура("гф_КМСтрокой, гф_ПринятыеКМ, Номенклатура, Характеристика, НомерСтроки");
				ЗаполнитьЗначенияСвойств(СтруктураЗаписи, стрТч);
				МассивКМДляЗаписи.Добавить(СтруктураЗаписи);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	// 4. сверка принятых кодов маркировки с кодами маркировки, которые были отправлены клиенту при отгрузке товара
	// В случае возврата товара с кодами маркировки, которые не передавались клиенту, 
	// но владельцем которых он является, коды маркировки записываются в справочник «Штрихкоды товаров и упаковок»
	СоздатьШтрихкодыУпаковокТоваров(МассивКМДляЗаписи);
		
КонецПроцедуры

&НаКлиенте
Процедура гф_СоздатьПриходныйОрдерНаТовары(Команда)
	
	Если Объект.Ссылка.Пустая()
		ИЛИ Не Объект.Проведен Тогда
		ПоказатьПредупреждение( , "Для создания Приходного ордера необходимо провести документ.", 30, "Проведение документа");
		Возврат;
	КонецЕсли;
	ОрдераПоРаспоряжению = гф_ПроверитьНаличиеПриходногоОрдераПоРаспоряжению(Объект.Ссылка);
	Если ОрдераПоРаспоряжению <> Неопределено Тогда
		ТекстВопроса = НСтр("ru='Уже существуют документы
		|(" + ОрдераПоРаспоряжению + "),
		|созданные на основании данной заявки на возврат. Продолжить?'");
		ДопПараметры = Новый Структура();
		Оповещение = Новый ОписаниеОповещения("гф_ВопросСоздатьПриходныйОрдерЗавершение", ЭтотОбъект, ДопПараметры);
		ПоказатьВопрос(Оповещение, ТекстВопроса, РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Нет);
	Иначе
		СоздатьПриходныйОрдерНаТоварыНаСервере();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура гф_ЗаказатьКМ(Команда)
	СтруктураПоиска = Новый Структура("гф_ЗаказатьКМ", Истина);
	мСтрокТЧ = Объект.ВозвращаемыеТовары.НайтиСтроки(СтруктураПоиска);
	Если мСтрокТЧ.Количество() = 0 Тогда
		ПоказатьПредупреждение( , "Нет данных для заказа кодов маркировки!", 30, "Заказ кодов маркировки");
		Возврат;
	КонецЕсли;
	Если Не Объект.Проведен Тогда
		ПоказатьПредупреждение( , "Для заказа кодов маркировки документ должен быть проведен!", 30, "Проведение документа");
		Возврат;
	КонецЕсли;
	СоздатьЗаказНаЭмиссиюКодовМаркировкиНаСервере();
	ПослеСозданияЗаказаНаЭмиссиюКлиент();
	МодифицированностьКэш = ЭтотОбъект.Модифицированность;
	Для каждого стрТч Из Объект.ВозвращаемыеТовары Цикл
		стрТч["гф_ЗаказатьКМ"] = Ложь;
	КонецЦикла;
	ЭтотОбъект.Модифицированность = МодифицированностьКэш;
КонецПроцедуры

&НаСервере
Процедура СоздатьЗаказНаЭмиссиюКодовМаркировкиНаСервере()
	ДопПараметры = Новый Структура("ВозвращаемыеТовары", Объект.ВозвращаемыеТовары);
	СтруктураДанныеЗаказаЭмиссии = 
	гф_ЭмиссияКодовМаркировкиВызовСервера.гф_СоздатьЗаказНаЭмиссиюКодовМаркировки(Объект.Ссылка, ДопПараметры);
	
	СтруктураЗаказНаЭмиссиюКодовМаркировки = СтруктураДанныеЗаказаЭмиссии;
КонецПроцедуры

&НаКлиенте
Процедура ПослеСозданияЗаказаНаЭмиссиюКлиент()

	ЗаказКодовВозможен = Неопределено;
	СтруктураЗаказНаЭмиссиюКодовМаркировки.Свойство("ЗаказКодовВозможен", ЗаказКодовВозможен);
	Если Не ЗаказКодовВозможен = Истина Тогда
		Возврат;	
	КонецЕсли;
	
	ЗаказНаЭмиссию = СтруктураЗаказНаЭмиссиюКодовМаркировки["ЗаказНаЭмиссиюКодовМаркировкиСУЗ"];
	
	лПараметры = Новый Структура("Ключ", ЗаказНаЭмиссию);
	ФормаЗаказаНаЭмиссию = ОткрытьФорму("Документ.ЗаказНаЭмиссиюКодовМаркировкиСУЗ.ФормаОбъекта", лПараметры);
	
	ПараметрыОбработкиДокументов = ИнтеграцияИСМПСлужебныйКлиентСервер.ПараметрыОбработкиДокументов();
	ПараметрыОбработкиДокументов.Ссылка = ЗаказНаЭмиссию;
	ПараметрыОбработкиДокументов.Организация = СтруктураЗаказНаЭмиссиюКодовМаркировки["Организация"];
	ПараметрыОбработкиДокументов.ДальнейшееДействие = ПредопределенноеЗначение(
	"Перечисление.ДальнейшиеДействияПоВзаимодействиюИСМП.ЗапроситеКодыМаркировки");
	
	// см. ИнтеграцияИСМПКлиент.ПодготовитьКПередаче()
	гф_ПодготовитьКПередаче(
	ФормаЗаказаНаЭмиссию,
	ФормаЗаказаНаЭмиссию.УникальныйИдентификатор,
	ПараметрыОбработкиДокументов);
	
	ФормаЗаказаНаЭмиссию.Записать();
	ФормаЗаказаНаЭмиссию.Закрыть();
	
	Если ЗначениеЗаполнено(ЗаказНаЭмиссию) Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю("Создан документ " + ЗаказНаЭмиссию);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура гф_ПодготовитьКПередаче(
	Форма, 
	Идентификатор, 
	ПараметрыОбработкиДокументов, 
	ОповещениеПриЗавершении = Неопределено)
	
	ВходящиеДанные = Новый Массив;
	ВходящиеДанные.Добавить(ПараметрыОбработкиДокументов);
	
	РезультатОбмена = ИнтеграцияИСМПВызовСервера.ПодготовитьКПередаче(
		ВходящиеДанные,
		Идентификатор);
	
	ИнтеграцияИСМПСлужебныйКлиент.ОбработатьРезультатОбмена(
		РезультатОбмена, Форма, Неопределено, ОповещениеПриЗавершении);

КонецПроцедуры

&НаКлиенте
Процедура гф_ЗагрузитьТоварыИзФайлаЗавершение(АдресЗагруженныхДанных, ДополнительныеПараметры) Экспорт
	Если АдресЗагруженныхДанных = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	гф_ЗагрузитьТоварыИзФайлаНаСервере(АдресЗагруженныхДанных);
	
	Для каждого стрТЧ Из Объект.ВозвращаемыеТовары Цикл
		Идентификатор = стрТЧ.ПолучитьИдентификатор();
		Элементы.ВозвращаемыеТовары.ТекущаяСтрока = Идентификатор;
		ВозвращаемыеТоварыНоменклатураПриИзменении(Элементы.ВозвращаемыеТовары);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура гф_ВопросСоздатьПриходныйОрдерЗавершение(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = КодВозвратаДиалога.Да Тогда
		СоздатьПриходныйОрдерНаТоварыНаСервере();
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция гф_ПроверитьНаличиеПриходногоОрдераПоРаспоряжению(Распоряжение)
	//СписокСсылок = Новый СписокЗначений;
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	ПРЕДСТАВЛЕНИЕССЫЛКИ(ПриходныйОрдерНаТовары.Ссылка) КАК Ссылка
	|ИЗ
	|	Документ.ПриходныйОрдерНаТовары КАК ПриходныйОрдерНаТовары
	|ГДЕ
	|	ПриходныйОрдерНаТовары.Распоряжение = &Распоряжение
	|	И НЕ ПриходныйОрдерНаТовары.ПометкаУдаления");
	
	Запрос.УстановитьПараметр("Распоряжение", Распоряжение);
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	Выборка = Результат.Выбрать();
	мСтрок = Новый Массив;
	Пока Выборка.Следующий() Цикл
		мСтрок.Добавить(Выборка["Ссылка"]);
	КонецЦикла;
	СписокСсылок = СтрСоединить(мСтрок, Символы.ПС);
	
	Возврат СписокСсылок;
	
КонецФункции

&НаКлиенте
Функция ПолучитьМассивШтрихкодов()
	
	// см. общаяФорма ЗагрузкаКодовМаркировкиИС.КодыМаркировкиИзТабличногоДокумента()
	Результат = Новый Массив;
	мОбработанныхШтрихкодов = Новый Массив;
	Для каждого СтрТч Из Объект.ВозвращаемыеТовары Цикл
		ФорматBase64 = Ложь;
		Если ЗначениеЗаполнено(СтрТч["гф_ПринятыеКМ"]) Тогда
			Штрихкод = ОбщегоНазначенияУТВызовСервера.ЗначениеРеквизитаОбъекта(стрТч["гф_ПринятыеКМ"], "ЗначениеШтрихкода");
		Иначе
			Штрихкод = СтрТч["гф_КМСтрокой"];	
		КонецЕсли;
		
		// не допускаем создания дублей
		Если мОбработанныхШтрихкодов.Найти(Штрихкод) <> Неопределено Тогда
			Продолжить;
		Иначе
			мОбработанныхШтрихкодов.Добавить(Штрихкод);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Штрихкод) Тогда
			СодержитНедопустимыеСимволы = Ложь;
			Если РазборКодаМаркировкиИССлужебныйКлиентСервер.НайденНедопустимыйСимволXML(Штрихкод) Тогда
				СодержитНедопустимыеСимволы = Истина;
			КонецЕсли;
			
			ШтрихкодУпаковки = "";
			Если СодержитНедопустимыеСимволы Тогда
				Штрихкод = ШтрихкодированиеИСКлиентСервер.ШтрихкодВBase64(Штрихкод);
				ФорматBase64 = Истина;
			КонецЕсли;
			
			ПоляСтроки = Новый Структура;
			ПоляСтроки.Вставить("Штрихкод",                          СокрЛП(Штрихкод));
			ПоляСтроки.Вставить("Количество",                        1);
			ПоляСтроки.Вставить("ШтрихкодМаркиАлкогольнойПродукции", "");
			ПоляСтроки.Вставить("ШтрихкодУпаковки",                  ШтрихкодУпаковки);
			ПоляСтроки.Вставить("ФорматBase64",                      ФорматBase64 Или СодержитНедопустимыеСимволы);
			
			Результат.Добавить(ПоляСтроки);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции 

&НаСервере
Процедура СоздатьПриходныйОрдерНаТоварыНаСервере()
	// создается документ ПриходныйОрдрерНаТовары с видом операции «Возврат не принятых получателем товаров».
	// Отправителем является Клиент. Табличная часть заполняется сопоставленными строками ТЧ «Товары» документа
	// «Заявка на возврат товаров от клиента».
	ДанныеЗаполнения = Новый Структура;
	ДанныеЗаполнения.Вставить("Склад", Объект.Склад);
	ДанныеЗаполнения.Вставить("Помещение");
	ДанныеЗаполнения.Вставить("Распоряжение", Объект.Ссылка);
	ДанныеЗаполнения.Вставить("ДатаПоступления", Объект.ДатаПоступления);
	ДанныеЗаполнения.Вставить("ЗонаПриемки");
	ДанныеЗаполнения.Вставить("СкладскаяОперация");
	ДанныеЗаполнения.Вставить("Отправитель", Объект.Партнер);
	ДанныеЗаполнения.Вставить("ДатаВходящегоДокумента");
	ДанныеЗаполнения.Вставить("НомерВходящегоДокумента");
	ДанныеЗаполнения.Вставить("ХозяйственнаяОперация", Объект.ХозяйственнаяОперация);
	ДанныеЗаполнения.Вставить("Ответственный", Пользователи.ТекущийПользователь());
	
	обПрихОрдер = Документы.ПриходныйОрдерНаТовары.СоздатьДокумент();
	обПрихОрдер.Дата = ТекущаяДатаСеанса();
	ЗаполнитьЗначенияСвойств(обПрихОрдер, ДанныеЗаполнения);
	обПрихОрдер.СкладскаяОперация = 
	СкладыКлиентСервер.СкладскаяОперацияПриемкиПоХозяйственнойОперации(обПрихОрдер.ХозяйственнаяОперация);
	тзВозвращаемыеТовары = Объект.ВозвращаемыеТовары.Выгрузить();
	гф_ЗаполнитьПриходныйОрдерТовары(обПрихОрдер, тзВозвращаемыеТовары);
	
	ОбъектМетаданныхСтатус = обПрихОрдер.Метаданные().Реквизиты.Статус; // ОбъектМетаданныхРеквизит
	обПрихОрдер.Статус = ОбъектМетаданныхСтатус.ЗначениеЗаполнения;
	
	обПрихОрдер.Склад = ЗначениеНастроекПовтИсп.ПолучитьСкладПоУмолчанию(обПрихОрдер.Склад);
	Если ЗначениеЗаполнено(обПрихОрдер.Склад) Тогда
		Если СкладыСервер.ИспользоватьАдресноеХранение(обПрихОрдер.Склад, обПрихОрдер.Помещение, обПрихОрдер.Дата) Тогда
			обПрихОрдер.ЗонаПриемки = 
			Справочники.СкладскиеЯчейки.ЗонаПриемкиПоУмолчанию(
			обПрихОрдер.Склад, 
			обПрихОрдер.Помещение, 
			обПрихОрдер.ЗонаПриемки);
		КонецЕсли;
	КонецЕсли;
	
	Попытка
		обПрихОрдер.Записать(РежимЗаписиДокумента.Проведение);
		ТекстСообщения = "Создан документ " + обПрихОрдер.Ссылка;
	Исключение
		ТекстСообщения = "Не удалось создать документ ""Приходный ордер на товары!""";
	КонецПопытки;
	ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
	
КонецПроцедуры

&НаСервере
Процедура гф_ЗаполнитьПриходныйОрдерТовары(обОрдер, тзТовары)
	
	обОрдер.Товары.Очистить();
	ПараметрыОтбора = Новый Структура("Отменено", Ложь);
	мСтрокТовары = тзТовары.НайтиСтроки(ПараметрыОтбора);
	тзТоварыКЗаполнению = тзТовары.Скопировать(мСтрокТовары);
	
	ВыборкаШтрихкодов = гф_ПолучитьШтрихкодыНоменклатуры(тзТоварыКЗаполнению);
	
	Для каждого стрТЗ Из тзТоварыКЗаполнению Цикл
		нс = обОрдер.Товары.Добавить();
		ЗаполнитьЗначенияСвойств(нс, стрТЗ, 
		"Номенклатура, Характеристика, Назначение, Количество, КоличествоУпаковок, гф_IDКороба");
		ВыборкаШтрихкодов.Сбросить();
		СтруктураПоиска = Новый Структура("Номенклатура, Характеристика", нс["Номенклатура"], нс["Характеристика"]);
		Если ВыборкаШтрихкодов.НайтиСледующий(СтруктураПоиска) Тогда
			нс["Штрихкод"] = ВыборкаШтрихкодов["Штрихкод"];
		КонецЕсли;
	КонецЦикла; 
	
	обОрдер["ВсегоМест"] = обОрдер.Товары.Итог("Количество");
КонецПроцедуры

&НаСервере
Функция гф_ПолучитьШтрихкодыНоменклатуры(тзТоварыКЗаполнению)
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	|	т.Номенклатура КАК Номенклатура,
	|	т.Характеристика КАК Характеристика
	|ПОМЕСТИТЬ ТоварыКЗаполнению
	|ИЗ
	|	&тзТоварыКЗаполнению КАК т
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЕСТЬNULL(ШтрихкодыНоменклатуры.Штрихкод, """") КАК Штрихкод,
	|	ТоварыКЗаполнению.Номенклатура КАК Номенклатура,
	|	ТоварыКЗаполнению.Характеристика КАК Характеристика
	|ИЗ
	|	ТоварыКЗаполнению КАК ТоварыКЗаполнению
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
	|		ПО ТоварыКЗаполнению.Номенклатура = ШтрихкодыНоменклатуры.Номенклатура
	|			И ТоварыКЗаполнению.Характеристика = ШтрихкодыНоменклатуры.Характеристика");
	Запрос.УстановитьПараметр("тзТоварыКЗаполнению", тзТоварыКЗаполнению);
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Возврат Выборка;
		
КонецФункции

&НаСервере
Процедура гф_ДобавитьЭлементыФормы()

	ТипГруппаФормы = Тип("ГруппаФормы");
	ТипПолеФормы = Тип("ПолеФормы");
	ТипКнопкаФормы = Тип("КнопкаФормы");
	ТипТаблицаФормы = Тип("ТаблицаФормы");
	
	// статус проверки возврата
	Элементы.ГруппаСтатус.Группировка = ГруппировкаПодчиненныхЭлементовФормы.Вертикальная;
	НовыйЭлемент  = Элементы.Добавить("гф_СтатусПроверкиВозврата", ТипПолеФормы, Элементы.ГруппаСтатус);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.гф_СтатусСверкиВозврата";
	
	// таблица гф_ТоварыВКоробах
	НовыйЭлемент = Элементы.Вставить("гф_СтраницаТоварыВКоробах", ТипГруппаФормы, Элементы.ГруппаСтраницы, 
					Элементы.ГруппаЗаменяющиеТовары);
	НовыйЭлемент.Вид = ВидГруппыФормы.Страница;
	НовыйЭлемент.Заголовок = "Товары в коробах";
	НовыйЭлемент.Подсказка = "Товары в коробах";
	НовыйЭлемент.Группировка = ГруппировкаПодчиненныхЭлементовФормы.Вертикальная;
	НовыйЭлемент.ПутьКДаннымЗаголовка = "Объект.гф_ТоварыВКоробах.КоличествоСтрок";
	
	ТаблицаФормы = Элементы.Вставить("гф_ТоварыВКоробах", ТипТаблицаФормы, Элементы.гф_СтраницаТоварыВКоробах);
	ТаблицаФормы.ПутьКДанным = "Объект.гф_ТоварыВКоробах";

	НовыйЭлемент  = Элементы.Добавить("гф_ТоварыВКоробахНомерСтроки", ТипПолеФормы, ТаблицаФормы);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ТоварыВКоробах.НомерСтроки";

	НовыйЭлемент  = Элементы.Добавить("гф_ТоварыВКоробахУпаковочныйЛист", ТипПолеФормы, ТаблицаФормы);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ТоварыВКоробах.УпаковочныйЛист";
	
	НовыйЭлемент  = Элементы.Добавить("гф_ТоварыВКоробахАртикул", ТипПолеФормы, ТаблицаФормы);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ТоварыВКоробах.Артикул";
	
	НовыйЭлемент  = Элементы.Добавить("гф_ТоварыВКоробахIDКороба", ТипПолеФормы, ТаблицаФормы);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ТоварыВКоробах.IDКороба";

	НовыйЭлемент  = Элементы.Добавить("гф_ТоварыВКоробахКоличествоПар", ТипПолеФормы, ТаблицаФормы);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.гф_ТоварыВКоробах.КоличествоПар";
	
	// реквзизиты в таблице ВозвращаемыеТовары
	НовыйЭлемент  = Элементы.Добавить("гф_ВозвращаемыеТоварыIDКороба", ТипПолеФормы, Элементы.ВозвращаемыеТовары);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.ВозвращаемыеТовары.гф_IDКороба";
	
	НовыйПараметр = Новый ПараметрВыбора("Отбор.ТипУпаковки", Перечисления.ТипыУпаковок.МаркированныйТовар);
	мПараметрыВыбора = Новый Массив();
	мПараметрыВыбора.Добавить(НовыйПараметр);
	фмПараметрыВыбора = Новый ФиксированныйМассив(мПараметрыВыбора);
	
	НовыйЭлемент  = Элементы.Добавить("гф_ВозвращаемыеТоварыПринятыеКМ", ТипПолеФормы, Элементы.ВозвращаемыеТовары);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.ВозвращаемыеТовары.гф_ПринятыеКМ";
	НовыйЭлемент.ПараметрыВыбора = фмПараметрыВыбора;

	НовыйЭлемент  = Элементы.Добавить("гф_ВозвращаемыеТоварыОтгруженныеКМ", ТипПолеФормы, Элементы.ВозвращаемыеТовары);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.ВозвращаемыеТовары.гф_ОтгруженныеКМ";
	НовыйЭлемент.ПараметрыВыбора = фмПараметрыВыбора;
	
	НовыйЭлемент  = Элементы.Добавить("гф_ВозвращаемыеТоварыПринятСкладом", ТипПолеФормы, Элементы.ВозвращаемыеТовары);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеФлажка;
	НовыйЭлемент.Заголовок = "Принят складом";
	НовыйЭлемент.ПутьКДанным = "Объект.ВозвращаемыеТовары.гф_ПринятСкладом";

	НовыйЭлемент  = Элементы.Добавить("гф_ВозвращаемыеТовары_КМСтрокой", ТипПолеФормы, Элементы.ВозвращаемыеТовары);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.ВозвращаемыеТовары.гф_КМСтрокой";
	
	НовыйЭлемент  = Элементы.Добавить("гф_ВозвращаемыеТоварыЗаказатьКМ", ТипПолеФормы, Элементы.ВозвращаемыеТовары);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеФлажка;
	НовыйЭлемент.Заголовок = "Заказать КМ";
	НовыйЭлемент.ПутьКДанным = "Объект.ВозвращаемыеТовары.гф_ЗаказатьКМ";
	
	НовыйЭлемент  = Элементы.Добавить("гф_ВозвращаемыеТовары_СтатусПроверкиКМ", ТипПолеФормы, Элементы.ВозвращаемыеТовары);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;      
	НовыйЭлемент.ПутьКДанным = "Объект.ВозвращаемыеТовары.гф_СтатусПроверкиКМ";
	НовыйЭлемент.Видимость = Ложь;
	
	НовыйЭлемент  = Элементы.Добавить("гф_ВозвращаемыеТоварыКлиентЯвляетсяВладельцемКМ", ТипПолеФормы, Элементы.ВозвращаемыеТовары);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеФлажка;
	НовыйЭлемент.Заголовок = "Заказать КМ";
	НовыйЭлемент.ПутьКДанным = "Объект.ВозвращаемыеТовары.гф_КлиентЯвляетсяВладельцемКМ";
	НовыйЭлемент.Видимость = Ложь;
	
	НовыйЭлемент  = Элементы.Добавить("гф_ВозвращаемыеТоварыПроизведенаПроверкаКМ", ТипПолеФормы, Элементы.ВозвращаемыеТовары);
	НовыйЭлемент.Вид = ВидПоляФормы.ПолеФлажка;
	НовыйЭлемент.Заголовок = "Заказать КМ";
	НовыйЭлемент.ПутьКДанным = "Объект.ВозвращаемыеТовары.гф_ПроизведенаПроверкаКМ";
	НовыйЭлемент.Видимость = Ложь;
	
	// группа команд для регистрации возвратов
	НовыйЭлемент = Элементы.Добавить("гф_ГруппаКнопокРегистрацияВозвратов",
		ТипГруппаФормы,
		Элементы.ВозвращаемыеТовары.КоманднаяПанель);
	НовыйЭлемент.Вид = ВидГруппыФормы.Подменю;
	НовыйЭлемент.Заголовок = "Регистрация возвратов (доп.)";
		
	// команда механизма загрузки из файла
	Команда = Команды.Добавить("гф_ЗагрузитьТоварыИзФайла");
	Команда.Заголовок = "Загрузить из файла по коду маркировки и GTIN";
	Команда.Действие = "гф_ЗагрузитьТоварыИзФайла";
	Команда.ИзменяетСохраняемыеДанные = Истина;
	Команда.Картинка = Команды.ЗагрузитьВозвращаемыеТоварыИзВнешнегоФайла.Картинка;
	Команда.Отображение = ОтображениеКнопки.КартинкаИТекст;
	
	НоваяКнопка = Элементы.Вставить("гф_КнопкаЗагрузитьТоварыИзФайла", 
		ТипКнопкаФормы, 
		Элементы.гф_ГруппаКнопокРегистрацияВозвратов);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ЗагрузитьТоварыИзФайла";
	
	// команда проверки возвращаемых товаров
	Команда = Команды.Добавить("гф_ПроверитьКМ");
	Команда.Заголовок = "Проверить КМ";
	Команда.Действие = "гф_ПроверитьКМ";
	Команда.ИзменяетСохраняемыеДанные = Истина;
	
	НоваяКнопка = Элементы.Вставить("гф_КнопкаПроверитьКМ", 
		ТипКнопкаФормы,
		Элементы.гф_ГруппаКнопокРегистрацияВозвратов);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ПроверитьКМ";

	// команда создания приходного ордера
	Команда = Команды.Добавить("гф_СоздатьПриходныйОрдерНаТовары");
	Команда.Заголовок = "Создать приходный ордер на товары";
	Команда.Действие = "гф_СоздатьПриходныйОрдерНаТовары";
	Команда.ИзменяетСохраняемыеДанные = Истина;
	
	НоваяКнопка = Элементы.Вставить("гф_КнопкаСоздатьПриходныйОрдерНаТовары", 
		ТипКнопкаФормы,
		Элементы.гф_ГруппаКнопокРегистрацияВозвратов);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_СоздатьПриходныйОрдерНаТовары";
	
	// команда создания заказа на эмиссию кодов маркировки
	Команда = Команды.Добавить("гф_ЗаказатьКМ");
	Команда.Заголовок = "Заказать КМ";
	Команда.Действие = "гф_ЗаказатьКМ";
	Команда.ИзменяетСохраняемыеДанные = Истина;
	
	НоваяКнопка = Элементы.Вставить("гф_КнопкаЗаказатьКМ", 
		ТипКнопкаФормы,
		Элементы.гф_ГруппаКнопокРегистрацияВозвратов);
	НоваяКнопка.Вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ЗаказатьКМ";

КонецПроцедуры

&НаСервере
Процедура гф_ЗагрузитьТоварыИзФайлаНаСервере(АдресЗагруженныхДанных)
	
	ЗагруженныеДанные = ПолучитьИзВременногоХранилища(АдресЗагруженныхДанных);
	Объект.ВозвращаемыеТовары.Очистить();
	ТоварыДобавлены = Ложь;
	Для каждого СтрокаТаблицы Из ЗагруженныеДанные Цикл 
		Если Не ЗначениеЗаполнено(СтрокаТаблицы.Номенклатура) Тогда 
			Продолжить;
		КонецЕсли;
		
		нс = Объект.ВозвращаемыеТовары.Добавить();
		нс.Номенклатура = СтрокаТаблицы.Номенклатура;
		нс.Характеристика = СтрокаТаблицы.Характеристика;
		нс.Количество = СтрокаТаблицы.Количество;
		нс.КоличествоУпаковок = СтрокаТаблицы.Количество;
		нс.гф_ПринятыеКМ = СтрокаТаблицы.гф_ПринятыеКМ;
		нс.гф_КМСтрокой = СтрокаТаблицы.гф_КМСтрокой;
		
		нс.ДатаПоступления = Объект.ДатаПоступления;
		ТоварыДобавлены = Истина;
	КонецЦикла;
	
		Если ТоварыДобавлены Тогда
		Модифицированность = Истина;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПроверитьЗаполнитьКМСтрокой()

	Для каждого СтрТч Из Объект.ВозвращаемыеТовары Цикл
		Если ЗначениеЗаполнено(СтрТч["гф_ПринятыеКМ"]) Тогда
		КМСтрокой = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрТч["гф_ПринятыеКМ"], "ЗначениеШтрихкода");
			СтрТч["гф_КМСтрокой"] = КМСтрокой;
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

&НаСервере
Функция ТекстЗапросаДокументыПродажи()
	
	Возврат "ВЫБРАТЬ
	|	т.НомерСтроки КАК НомерСтроки,
	|	т.гф_КМСтрокой КАК КМСтрокой,
	|	т.гф_КлиентЯвляетсяВладельцемКМ КАК КлиентЯвляетсяВладельцемКМ,
	|	т.гф_ПринятыеКМ КАК ПринятыеКМ,
	|	т.Номенклатура КАК Номенклатура,
	|	т.Характеристика КАК Характеристика
	|ПОМЕСТИТЬ вт_Товары
	|ИЗ
	|	&табДанные КАК т
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура,
	|	Характеристика
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	вт_Товары.НомерСтроки КАК НомерСтроки,
	|	вт_Товары.КМСтрокой КАК КМСтрокой,
	|	вт_Товары.КлиентЯвляетсяВладельцемКМ КАК КлиентЯвляетсяВладельцемКМ,
	|	спрШтрихкоды.Ссылка КАК ШтрихкодСсылка,
	|	ШтрихкодыНоменклатуры.Номенклатура КАК Номенклатура,
	|	ШтрихкодыНоменклатуры.Характеристика КАК Характеристика,
	|	ШтрихкодыНоменклатуры.Штрихкод КАК GTIN
	|ПОМЕСТИТЬ ИскомыеШтрихкоды
	|ИЗ
	|	вт_Товары КАК вт_Товары
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК спрШтрихкоды
	|		ПО вт_Товары.КМСтрокой = спрШтрихкоды.ЗначениеШтрихкода
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
	|		ПО вт_Товары.Номенклатура = ШтрихкодыНоменклатуры.Номенклатура
	|			И вт_Товары.Характеристика = ШтрихкодыНоменклатуры.Характеристика
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИскомыеШтрихкоды.КМСтрокой КАК КМСтрокой,
	|	ИскомыеШтрихкоды.ШтрихкодСсылка КАК КМСсылка,
	|	ИскомыеШтрихкоды.Номенклатура КАК Номенклатура,
	|	ИскомыеШтрихкоды.Характеристика КАК Характеристика,
	|	ИскомыеШтрихкоды.GTIN КАК GTIN,
	|	ВЫРАЗИТЬ(ДвижениеКодов.Регистратор КАК Документ.РеализацияТоваровУслуг) КАК Регистратор,
	|	ВЫРАЗИТЬ(ДвижениеКодов.Регистратор КАК Документ.РеализацияТоваровУслуг).Дата КАК Дата
	|ПОМЕСТИТЬ Регистраторы
	|ИЗ
	|	ИскомыеШтрихкоды КАК ИскомыеШтрихкоды
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ВлШтрихкоды
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрНакопления.гф_ДвижениеКодовМаркировкиОрганизации.Обороты(, &КонецПериода, Регистратор, Склад = &Клиент) КАК ДвижениеКодов
	|			ПО ВлШтрихкоды.Ссылка = ДвижениеКодов.КМ
	|		ПО (ВлШтрихкоды.Штрихкод = ИскомыеШтрихкоды.ШтрихкодСсылка)
	|ГДЕ
	|	ВЫРАЗИТЬ(ДвижениеКодов.Регистратор КАК Документ.РеализацияТоваровУслуг) ЕСТЬ НЕ NULL 
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ИскомыеШтрихкоды.КМСтрокой,
	|	ИскомыеШтрихкоды.ШтрихкодСсылка,
	|	ИскомыеШтрихкоды.Номенклатура,
	|	ИскомыеШтрихкоды.Характеристика,
	|	ИскомыеШтрихкоды.GTIN,
	|	ВЫРАЗИТЬ(ДвижениеКодов.Регистратор КАК Документ.РеализацияТоваровУслуг),
	|	ВЫРАЗИТЬ(ДвижениеКодов.Регистратор КАК Документ.РеализацияТоваровУслуг).Дата
	|ИЗ
	|	ИскомыеШтрихкоды КАК ИскомыеШтрихкоды
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрНакопления.гф_ДвижениеКодовМаркировкиОрганизации.Обороты(, &КонецПериода, Регистратор, Склад = &Клиент) КАК ДвижениеКодов
	|		ПО ИскомыеШтрихкоды.ШтрихкодСсылка = ДвижениеКодов.КМ
	|ГДЕ
	|	ВЫРАЗИТЬ(ДвижениеКодов.Регистратор КАК Документ.РеализацияТоваровУслуг) ЕСТЬ НЕ NULL 
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	КМСтрокой,
	|	Номенклатура,
	|	Характеристика
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИскомыеШтрихкоды.НомерСтроки КАК НомерСтроки,
	|	ИскомыеШтрихкоды.Номенклатура КАК Номенклатура,
	|	ИскомыеШтрихкоды.Характеристика КАК Характеристика,
	|	ИскомыеШтрихкоды.GTIN КАК GTIN,
	|	ИскомыеШтрихкоды.КМСтрокой КАК КМСтрокой,
	|	ИскомыеШтрихкоды.КлиентЯвляетсяВладельцемКМ КАК КлиентЯвляетсяВладельцемКМ,
	|	Регистраторы.Регистратор КАК ДокументРеализации,
	|	Регистраторы.Дата КАК Дата,
	|	РеализацияТоваровУслугТовары.Цена КАК Цена,
	|	РеализацияТоваровУслугТовары.СтавкаНДС КАК СтавкаНДС,
	|	1 КАК Количество,
	|	1 КАК КоличествоУпаковок
	|ПОМЕСТИТЬ Данные
	|ИЗ
	|	ИскомыеШтрихкоды КАК ИскомыеШтрихкоды
	|		ЛЕВОЕ СОЕДИНЕНИЕ Регистраторы КАК Регистраторы
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг.Товары КАК РеализацияТоваровУслугТовары
	|			ПО Регистраторы.Регистратор = РеализацияТоваровУслугТовары.Ссылка
	|				И Регистраторы.Номенклатура = РеализацияТоваровУслугТовары.Номенклатура
	|				И Регистраторы.Характеристика = РеализацияТоваровУслугТовары.Характеристика
	|		ПО ИскомыеШтрихкоды.КМСтрокой = Регистраторы.КМСтрокой
	|			И ИскомыеШтрихкоды.Номенклатура = Регистраторы.Номенклатура
	|			И ИскомыеШтрихкоды.Характеристика = Регистраторы.Характеристика
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Данные.НомерСтроки КАК НомерСтроки,
	|	Данные.КМСтрокой КАК КМСтрокой,
	|	РеализацияТоваровУслуг.Ссылка КАК ДокументРеализации,
	|	РеализацияТоваровУслуг.Дата КАК Дата,
	|	РеализацияТоваровУслугТовары.Цена КАК Цена,
	|	РеализацияТоваровУслугТовары.СтавкаНДС КАК СтавкаНДС,
	|	1 КАК Количество,
	|	1 КАК КоличествоУпаковок
	|ИЗ
	|	Данные КАК Данные
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг.Товары КАК РеализацияТоваровУслугТовары
	|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	|			ПО (РеализацияТоваровУслугТовары.Ссылка = РеализацияТоваровУслуг.Ссылка)
	|		ПО (Данные.Номенклатура = РеализацияТоваровУслугТовары.Номенклатура)
	|			И (Данные.Характеристика = РеализацияТоваровУслугТовары.Характеристика)
	|ГДЕ
	|	Данные.КлиентЯвляетсяВладельцемКМ
	|	И Данные.ДокументРеализации ЕСТЬ NULL
	|	И РеализацияТоваровУслуг.Контрагент = &Клиент
	|	И РеализацияТоваровУслуг.Дата <= &КонецПериода
	|
	|УПОРЯДОЧИТЬ ПО
	|	КМСтрокой,
	|	Дата УБЫВ";
	
КонецФункции

&НаСервере
Процедура СоздатьШтрихкодыУпаковокТоваров(МассивКМДляЗаписи);

	Для каждого Эл Из МассивКМДляЗаписи Цикл
		
		Если Не ЗначениеЗаполнено(Эл["гф_ПринятыеКМ"]) Тогда
			
			ссШтрихкодУпаковки = Справочники.ШтрихкодыУпаковокТоваров.НайтиПоРеквизиту("ЗначениеШтрихкода", Эл["гф_КМСтрокой"]);
			Если ЗначениеЗаполнено(ссШтрихкодУпаковки) Тогда
				обШтрихкодУпаковки = ссШтрихкодУпаковки.ПолучитьОбъект();
			Иначе
				обШтрихкодУпаковки = Справочники.ШтрихкодыУпаковокТоваров.СоздатьЭлемент();
			КонецЕсли;
			
			Если обШтрихкодУпаковки.ЭтоНовый() Тогда
				обШтрихкодУпаковки.ТипУпаковки = Перечисления.ТипыУпаковок.МаркированныйТовар;
			КонецЕсли;
			Если обШтрихкодУпаковки.ЭтоНовый() Тогда
				обШтрихкодУпаковки.ТипШтрихкода = Перечисления.ТипыШтрихкодов.GS1_DataMatrix;
			КонецЕсли;
			Если обШтрихкодУпаковки["ЗначениеШтрихкода"] <> Эл["гф_КМСтрокой"] Тогда
				обШтрихкодУпаковки["ЗначениеШтрихкода"] = Эл["гф_КМСтрокой"];
			КонецЕсли;
			Если обШтрихкодУпаковки["Номенклатура"] <> Эл["Номенклатура"] Тогда
				обШтрихкодУпаковки["Номенклатура"] = Эл["Номенклатура"];
			КонецЕсли;
			Если обШтрихкодУпаковки["Характеристика"] <> Эл["Характеристика"] Тогда
				обШтрихкодУпаковки["Характеристика"] = Эл["Характеристика"];
			КонецЕсли;
			Если Не ЗначениеЗаполнено(обШтрихкодУпаковки["Ответственный"]) Тогда
				обШтрихкодУпаковки["Ответственный"] = Пользователи.АвторизованныйПользователь();
			КонецЕсли;
			
			Если обШтрихкодУпаковки.ЭтоНовый()
				ИЛИ обШтрихкодУпаковки.Модифицированность() Тогда
				Попытка
					обШтрихкодУпаковки.Записать();
					ОбщегоНазначения.СообщитьПользователю("Записан элемент справочника ""Штрихкоды упаковок товаров"": " +
					обШтрихкодУпаковки.Ссылка);
				Исключение
					ОбщегоНазначения.СообщитьПользователю("Не удалось записать элемент справочника ""Штрихкоды упаковок товаров"" 
					|с значением штрихкода " + Эл["гф_КМСтрокой"]);
				КонецПопытки;	
			КонецЕсли;
			Если ЗначениеЗаполнено(обШтрихкодУпаковки.Ссылка) Тогда
				// заполним поле в строке ТЧ документа	
				СтруктураОтбора = Новый Структура("НомерСтроки, гф_КМСтрокой",  Эл["НомерСтроки"], Эл["гф_КМСтрокой"]);
				мСтрокТч = Объект.ВозвращаемыеТовары.НайтиСтроки(СтруктураОтбора);
				Если мСтрокТч.Количество() > 0 Тогда
					мСтрокТч[0]["гф_ПринятыеКМ"] = обШтрихкодУпаковки.Ссылка;
				КонецЕсли;
			КонецЕсли;	
		КонецЕсли;
		
	КонецЦикла;

КонецПроцедуры

#КонецОбласти