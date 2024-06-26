﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

&После("ПередЗаписью")
Процедура ИК_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если НЕ Отказ
		И РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
		// Галфинд_ДомнышеваКР_01_02_2024_Не проверять публикацию для операции Агрегация
		Если Операция <> Перечисления.ВидыОперацийИСМП.Агрегация Тогда
		ВсеТоварыОпубликованы = ПроверитьПубликациюТоваров();
		Если НЕ ВсеТоварыОпубликованы Тогда
			// vvv Галфинд \ Sakovich 04.04.2024
			Если Не ДополнительныеСвойства.Свойство("НеОпубликованыТовары") Тогда
				ДополнительныеСвойства.Вставить("НеОпубликованыТовары");
			КонецЕсли;
			// ^^^ Галфинд \ Sakovich 04.04.2024
			Отказ = Истина;
			Сообщить("Не все товары по документу опубликованы");	
		КонецЕсли;
		КонецЕсли; // Галфинд_ДомнышеваКР_01_02_2024
		ПроверитьДействиеУстановитьСтатус(); //Галфинд_ДомнышеваКР_16_01_2024
	КонецЕсли; 
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПроверитьПубликациюТоваров()
	
	ТЗТовары = Товары.Выгрузить();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	МаркировкаТоваровИСМПТовары.Номенклатура КАК Номенклатура,
		|	МаркировкаТоваровИСМПТовары.Характеристика КАК Характеристика
		|ПОМЕСТИТЬ ВТ_Товары
		|ИЗ
		|	&Товары КАК МаркировкаТоваровИСМПТовары
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_Товары.Номенклатура КАК Номенклатура,
		|	ВТ_Товары.Характеристика КАК Характеристика
		|ИЗ
		|	ВТ_Товары КАК ВТ_Товары
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
		|		ПО ВТ_Товары.Номенклатура = ШтрихкодыНоменклатуры.Номенклатура
		|			И ВТ_Товары.Характеристика = ШтрихкодыНоменклатуры.Характеристика
		|ГДЕ
		|	ШтрихкодыНоменклатуры.гф_СостояниеВыгрузкиНоменклатуры ЕСТЬ NULL
		|		ИЛИ ШтрихкодыНоменклатуры.гф_СостояниеВыгрузкиНоменклатуры <> ЗНАЧЕНИЕ(Перечисление.гф_СтатусыGTIN_В_НК.Опубликован)";
	
	Запрос.УстановитьПараметр("Товары", ТЗТовары);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса.Пустой();
	
КонецФункции	

// #wortmann {
// Процедура Проверяет документ и Заполняет статус ВОбороте для всех ШК по документу у которых установлен иной 
// Галфинд_Домнышева 2024/01/18	
Процедура ПроверитьДействиеУстановитьСтатус() 
	
	Период = ТекущаяДатаСеанса();
	Если ДокументПодходитПоУсловию() Тогда
		
			Если ЭтоОперацияВводаВОборот(ЭтотОбъект.Операция) Тогда
				СтатусВОбороте = Перечисления.гф_СтатусыКМ_в_ШК.ВОбороте;
				Для каждого стрШК Из ШтрихкодыУпаковок Цикл
					Если ЗначениеЗаполнено(стрШК["ШтрихкодУпаковки"]) 
						И стрШК["ШтрихкодУпаковки"]["ТипУпаковки"] = Перечисления.ТипыУпаковок.МаркированныйТовар 
						И стрШК["ШтрихкодУпаковки"]["гф_Статус"] <> СтатусВОбороте Тогда
						обШК = стрШК["ШтрихкодУпаковки"].ПолучитьОбъект();
						Если обШК <> Неопределено Тогда
							обШК.гф_Статус = СтатусВОбороте;
							обШК.Записать();
							гф_ЭмиссияКодовМаркировкиВызовСервера.ЗаписатьИсторияСтатусовКМ(Период, стрШК["ШтрихкодУпаковки"], СтатусВОбороте, Ссылка);
						КонецЕсли;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;

	КонецЕсли;
	
КонецПроцедуры// } #wortmann

// #wortmann {
// Функция проверяет документ по статусу и Дальнейшему действию в РС СтатусыДокументовИСМП 
// Галфинд_Домнышева 2024/01/18
Функция ДокументПодходитПоУсловию() 
	
	МассивДействий = Новый Массив;
	МассивДействий.Добавить(Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.НеТребуется);
	МассивДействий.Добавить(Перечисления.ДальнейшиеДействияПоВзаимодействиюИСМП.ВыполнитеАгрегацию);
	Статус = Перечисления.СтатусыОбработкиМаркировкиТоваровИСМП.КодыМаркировкиВведеныВОборот;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СтатусыДокументовИСМП.Документ КАК Документ,
		|	СтатусыДокументовИСМП.Статус КАК Статус,
		|	СтатусыДокументовИСМП.ДальнейшееДействие1 КАК ДальнейшееДействие1
		|ИЗ
		|	РегистрСведений.СтатусыДокументовИСМП КАК СтатусыДокументовИСМП
		|ГДЕ
		|	СтатусыДокументовИСМП.Документ = &Документ
		|	И СтатусыДокументовИСМП.Статус = &Статус
		|	И СтатусыДокументовИСМП.ДальнейшееДействие1 В(&МассивДействий)";
	
	Запрос.УстановитьПараметр("Документ", Ссылка);
	Запрос.УстановитьПараметр("МассивДействий", МассивДействий);
	Запрос.УстановитьПараметр("Статус", Статус);
	
	РезультатЗапроса = Запрос.Выполнить();

	Если Не РезультатЗапроса.Пустой() Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции// } #wortmann  

// Взято из ОМ гф_ЭмиссияКодовМаркировкиВызовСервера
Функция ЭтоОперацияВводаВОборот(Операция)
	
	Операции = Новый Массив;
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборот);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотМаркировкаОстатков);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотПолучениеПродукцииОтФизическихЛиц);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотПроизводствоВнеЕАЭС);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотПроизводствоРФ);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотПроизводствоРФПоДоговору);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотТрансграничнаяТорговля);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотПроизводствоРФПоДоговоруНаСторонеЗаказчика);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотИмпортСФТС);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотИмпортСФТСМех);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ВводВОборотКонтрактноеПроизводствоЕАЭС);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ИндивидуализацияКИЗ);

	Операции.Добавить(Перечисления.ВидыОперацийИСМП.ОтчетОВерификацииНанесенныхКМ);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.УдалитьОтчетОПередачеКМНаПринтер);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.УдалитьОтчетОПередачеКМНаПроизводственнуюЛинию);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.УдалитьОтчетОПечатиКМ);
	Операции.Добавить(Перечисления.ВидыОперацийИСМП.УдалитьОтчетОПотереРаспечатанныхКМ);
	
	Возврат Операции.Найти(Операция) <> Неопределено;
	
КонецФункции// } #wortmann 

#КонецОбласти

#КонецЕсли