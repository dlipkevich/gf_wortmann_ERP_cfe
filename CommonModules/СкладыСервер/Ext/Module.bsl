﻿
&ИзменениеИКонтроль("ПереоформитьРасходныеОрдера")
Функция гф_ПереоформитьРасходныеОрдера(Параметры)

	УстановитьПривилегированныйРежим(Истина);
	ОбщегоНазначения.ПриНачалеВыполненияРегламентногоЗадания();

	ОформленныеОрдера = Новый ТаблицаЗначений;
	ОформленныеОрдера.Колонки.Добавить("РасходныйОрдер",	Новый ОписаниеТипов("ДокументСсылка.РасходныйОрдерНаТовары"));
	ОформленныеОрдера.Колонки.Добавить("Номер",				Новый ОписаниеТипов("Строка"));
	ОформленныеОрдера.Колонки.Добавить("ДатаОтгрузки",		Новый ОписаниеТипов("Дата"));
	ОформленныеОрдера.Колонки.Добавить("Склад",				Новый ОписаниеТипов("СправочникСсылка.Склады"));
	ОформленныеОрдера.Колонки.Добавить("Помещение",			Новый ОписаниеТипов("СправочникСсылка.СкладскиеПомещения"));
	ОформленныеОрдера.Колонки.Добавить("Действие",			Новый ОписаниеТипов("Строка"));

	ОрдерЗаписан = Ложь;
	ЕстьОшибка = Ложь;
	ТекущаяДата = ТекущаяДатаСеанса();
	НачинатьОтгрузкуПослеФормированияЗаданияНаПеревозку = СкладыСервер.НачинатьОтгрузкуПослеФормированияЗаданияНаПеревозку(Параметры.Склад);
	СначалаНакладные = Константы.ПорядокОформленияНакладныхРасходныхОрдеров.Получить() = Перечисления.ПорядокОформленияНакладныхРасходныхОрдеров.СначалаНакладные;    

	Если Не Параметры.свойство("СозданныеРасходныеОрдера") Тогда
		ОбъединитьОрдераПоТекущуюДату(Параметры, ТекущаяДата, ОформленныеОрдера);
	КонецЕсли;

	СтруктураТоварыДляОформленияРасходныхОрдеров = ВычислитьТоварыДляОформленияРасходныхОрдеров(Параметры, НачинатьОтгрузкуПослеФормированияЗаданияНаПеревозку, СначалаНакладные);	
	ДеревоТоварыКОтгрузке = СтруктураТоварыДляОформленияРасходныхОрдеров.ДеревоТоварыКОтгрузке;
	ТоварыКСборке = СтруктураТоварыДляОформленияРасходныхОрдеров.ТоварыКСборке;

	Если Не Параметры.свойство("СозданныеРасходныеОрдера") Тогда
		УменьшитьКоличествоВОрдерах(ТоварыКСборке, ОформленныеОрдера, ОрдерЗаписан);	
	КонецЕсли;

	ТаблицаНоменклатурыДляЗапроса = ОбщегоНазначенияУТ.ДанныеДерева(ДеревоТоварыКОтгрузке, 6);

	ТаблицаНоменклатурыДляЗапроса = РаспределитьОтрицательныеКоличество(ТаблицаНоменклатурыДляЗапроса);

	Запрос = Новый Запрос;
	ТекстЗапроса = ТекстЗапросаСкладскаяОперацияТипДокумента() +
	"ВЫБРАТЬ
	|	ТоварыКОтгрузкеОстатки.ЗаданиеНаПеревозку,
	|	ТоварыКОтгрузкеОстатки.ОтгрузкаПоЗаданиюНаПеревозку,
	|	ТоварыКОтгрузкеОстатки.ДокументОтгрузки,
	|	ТоварыКОтгрузкеОстатки.Склад,
	|	ТоварыКОтгрузкеОстатки.Получатель,
	|	ВЫБОР
	|		КОГДА &ТекущаяДата > ТоварыКОтгрузкеОстатки.Период
	|			ТОГДА &ТекущаяДата
	|		ИНАЧЕ ТоварыКОтгрузкеОстатки.Период
	|	КОНЕЦ КАК ДатаОтгрузки,
	|	ТоварыКОтгрузкеОстатки.Номенклатура,
	|	ТоварыКОтгрузкеОстатки.Характеристика,
	|	ТоварыКОтгрузкеОстатки.Серия,
	|	ТоварыКОтгрузкеОстатки.Назначение,
	|	ТоварыКОтгрузкеОстатки.Количество КАК Количество,
	|	ТоварыКОтгрузкеОстатки.ДопустимоеОтклонение КАК ДопустимоеОтклонение
	|ПОМЕСТИТЬ ТаблицаНоменклатурыДляЗапроса
	|ИЗ
	|	&ТаблицаНоменклатурыДляЗапроса КАК ТоварыКОтгрузкеОстатки
	|ГДЕ
	|	ТоварыКОтгрузкеОстатки.Количество > ТоварыКОтгрузкеОстатки.ДопустимоеОтклонение
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	| ТаблицаНоменклатурыДляЗапроса.Склад,
	| ТаблицаНоменклатурыДляЗапроса.Номенклатура,
	| ТаблицаНоменклатурыДляЗапроса.Характеристика,
	| ТаблицаНоменклатурыДляЗапроса.Серия,
	| ТаблицаНоменклатурыДляЗапроса.Назначение,
	| СУММА(ТаблицаНоменклатурыДляЗапроса.Количество) КАК Количество
	|ПОМЕСТИТЬ ТаблицаНоменклатуры
	|ИЗ
	| ТаблицаНоменклатурыДляЗапроса КАК ТаблицаНоменклатурыДляЗапроса
	|
	|СГРУППИРОВАТЬ ПО
	| ТаблицаНоменклатурыДляЗапроса.Склад,
	| ТаблицаНоменклатурыДляЗапроса.Характеристика,
	| ТаблицаНоменклатурыДляЗапроса.Номенклатура,
	| ТаблицаНоменклатурыДляЗапроса.Серия,
	| ТаблицаНоменклатурыДляЗапроса.Назначение
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТаблицаНоменклатурыДляЗапроса.ЗаданиеНаПеревозку КАК ЗаданиеНаПеревозку,
	|	ТаблицаНоменклатурыДляЗапроса.ОтгрузкаПоЗаданиюНаПеревозку КАК ОтгрузкаПоЗаданиюНаПеревозку,
	|	ТаблицаНоменклатурыДляЗапроса.Склад КАК Склад,
	|	ТаблицаНоменклатурыДляЗапроса.Получатель КАК Получатель,
	|	ВЫБОР
	|		КОГДА ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки ССЫЛКА Документ.ЗаказКлиента
	|				ИЛИ ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки ССЫЛКА Документ.ПередачаТоваровХранителю
	|				ИЛИ ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки ССЫЛКА Документ.РеализацияТоваровУслуг
	|			ТОГДА ВЫБОР
	|					КОГДА ЕСТЬNULL(ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки.Соглашение.РазбиватьРасходныеОрдераПоРаспоряжениям, ЛОЖЬ)
	|						ТОГДА ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки
	|					ИНАЧЕ НЕОПРЕДЕЛЕНО
	|				КОНЕЦ
	|		ИНАЧЕ НЕОПРЕДЕЛЕНО
	|	КОНЕЦ КАК РаспоряжениеГруппировка,
	|	ТаблицаНоменклатурыДляЗапроса.ДатаОтгрузки КАК ДатаОтгрузки,	
	|	СкладскаяОперацияТипДокумента.СкладскаяОперация КАК СкладскаяОперация,
	|	ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки КАК Распоряжение,	
	|	ТаблицаНоменклатурыДляЗапроса.Номенклатура КАК Номенклатура,
	|	ТаблицаНоменклатурыДляЗапроса.Номенклатура.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	ТаблицаНоменклатурыДляЗапроса.Характеристика КАК Характеристика,
	|	ТаблицаНоменклатурыДляЗапроса.Серия КАК Серия,
	|	ТаблицаНоменклатурыДляЗапроса.Назначение КАК Назначение,
	|	ТаблицаНоменклатурыДляЗапроса.ДопустимоеОтклонение КАК ДопустимоеОтклонение,
	|	СУММА(ТаблицаНоменклатурыДляЗапроса.Количество) КАК Количество
	|ИЗ
	|	ТаблицаНоменклатурыДляЗапроса КАК ТаблицаНоменклатурыДляЗапроса
	|		ЛЕВОЕ СОЕДИНЕНИЕ СкладскаяОперацияТипДокумента КАК СкладскаяОперацияТипДокумента
	|		ПО ТИПЗНАЧЕНИЯ(ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки) = СкладскаяОперацияТипДокумента.Тип
	|			И ВЫБОР
	|				КОГДА ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки ССЫЛКА Документ.ЗаказНаСборку
	|					ТОГДА ВЫРАЗИТЬ(ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки КАК Документ.ЗаказНаСборку).ХозяйственнаяОперация
	|				КОГДА ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки ССЫЛКА Документ.СборкаТоваров
	|					ТОГДА ВЫРАЗИТЬ(ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки КАК Документ.СборкаТоваров).ХозяйственнаяОперация
	|				ИНАЧЕ НЕОПРЕДЕЛЕНО
	|			КОНЕЦ = СкладскаяОперацияТипДокумента.ХозяйственнаяОперация
	|
	|СГРУППИРОВАТЬ ПО
	|	ТаблицаНоменклатурыДляЗапроса.ЗаданиеНаПеревозку,
	|	ТаблицаНоменклатурыДляЗапроса.ОтгрузкаПоЗаданиюНаПеревозку,
	|	ТаблицаНоменклатурыДляЗапроса.Склад,
	|	ТаблицаНоменклатурыДляЗапроса.Получатель,
	|	ВЫБОР
	|		КОГДА ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки ССЫЛКА Документ.ЗаказКлиента
	|				ИЛИ ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки ССЫЛКА Документ.ПередачаТоваровХранителю
	|				ИЛИ ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки ССЫЛКА Документ.РеализацияТоваровУслуг
	|			ТОГДА ВЫБОР
	|					КОГДА ЕСТЬNULL(ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки.Соглашение.РазбиватьРасходныеОрдераПоРаспоряжениям, ЛОЖЬ)
	|						ТОГДА ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки
	|					ИНАЧЕ НЕОПРЕДЕЛЕНО
	|				КОНЕЦ
	|		ИНАЧЕ НЕОПРЕДЕЛЕНО
	|	КОНЕЦ,
	|	ТаблицаНоменклатурыДляЗапроса.ДатаОтгрузки,
	|	СкладскаяОперацияТипДокумента.СкладскаяОперация,
	|	ТаблицаНоменклатурыДляЗапроса.ДокументОтгрузки,
	|	ТаблицаНоменклатурыДляЗапроса.Номенклатура,
	|	ТаблицаНоменклатурыДляЗапроса.Характеристика,
	|	ТаблицаНоменклатурыДляЗапроса.Серия,
	|	ТаблицаНоменклатурыДляЗапроса.Назначение,
	|	ТаблицаНоменклатурыДляЗапроса.ДопустимоеОтклонение
	|
	|УПОРЯДОЧИТЬ ПО
	|	ТаблицаНоменклатурыДляЗапроса.Номенклатура.Наименование,
	|	ТаблицаНоменклатурыДляЗапроса.Характеристика.Наименование,
	|	ТаблицаНоменклатурыДляЗапроса.ДатаОтгрузки
	|
	|ИТОГИ ПО
	|	ОтгрузкаПоЗаданиюНаПеревозку,
	|	ЗаданиеНаПеревозку,	
	|	Склад,
	|	Получатель,
	|	РаспоряжениеГруппировка,	
	|	ДатаОтгрузки,
	|	СкладскаяОперация
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	| ТоварыНаСкладахОстатки.Номенклатура КАК Номенклатура,
	| ТоварыНаСкладахОстатки.Характеристика КАК Характеристика,
	| ТаблицаНоменклатуры.Серия КАК Серия,
	| ТоварыНаСкладахОстатки.Назначение КАК Назначение,
	| ТоварыНаСкладахОстатки.Склад КАК Склад,
	| ТоварыНаСкладахОстатки.Помещение КАК Помещение,
	| СУММА(0) КАК РейтингПомещения,
	| СУММА(0) КАК КоличествоВсего,
	| СУММА(0) КАК КоличествоВБазовыхИзрасходовано,
	| СУММА(ТоварыНаСкладахОстатки.ВНаличииОстаток - ТоварыНаСкладахОстатки.КОтгрузкеОстаток) КАК СвободныйОстатокВБазовых
	|ИЗ
	| РегистрНакопления.ТоварыНаСкладах.Остатки(
	|     ,
	|     (Номенклатура, Характеристика, Назначение, Склад) В
	|         (ВЫБРАТЬ
	|           ТаблицаНоменклатуры.Номенклатура,
	|           ТаблицаНоменклатуры.Характеристика,
	|           ТаблицаНоменклатуры.Назначение,
	|           ТаблицаНоменклатуры.Склад
	|         ИЗ
	|           ТаблицаНоменклатуры КАК ТаблицаНоменклатуры)
	|       И (&ПоВсемПомещениям
	|         ИЛИ Помещение = &Помещение)) КАК ТоварыНаСкладахОстатки
	|   ВНУТРЕННЕЕ СОЕДИНЕНИЕ ТаблицаНоменклатуры КАК ТаблицаНоменклатуры
	|   ПО ТоварыНаСкладахОстатки.Номенклатура = ТаблицаНоменклатуры.Номенклатура
	|     И ТоварыНаСкладахОстатки.Характеристика = ТаблицаНоменклатуры.Характеристика
	|     И ТоварыНаСкладахОстатки.Склад = ТаблицаНоменклатуры.Склад
	|     И ТоварыНаСкладахОстатки.Назначение = ТаблицаНоменклатуры.Назначение
	|     И (ВЫБОР
	|       КОГДА ТаблицаНоменклатуры.Серия = ЗНАЧЕНИЕ(Справочник.СерииНоменклатуры.ПустаяСсылка)
	|         ТОГДА ИСТИНА
	|       ИНАЧЕ ТаблицаНоменклатуры.Серия = ТоварыНаСкладахОстатки.Серия
	|     КОНЕЦ)
	|
	|СГРУППИРОВАТЬ ПО
	| ТоварыНаСкладахОстатки.Помещение,
	| ТаблицаНоменклатуры.Серия,
	| ТоварыНаСкладахОстатки.Склад,
	| ТоварыНаСкладахОстатки.Характеристика,
	| ТоварыНаСкладахОстатки.Номенклатура,
	| ТоварыНаСкладахОстатки.Назначение
	|
	|ИМЕЮЩИЕ
	| СУММА(ТоварыНаСкладахОстатки.ВНаличииОстаток - ТоварыНаСкладахОстатки.КОтгрузкеОстаток) > 0
	|
	|УПОРЯДОЧИТЬ ПО
	| ТоварыНаСкладахОстатки.Номенклатура.Наименование,
	| ТоварыНаСкладахОстатки.Характеристика.Наименование
	|ИТОГИ
	| СУММА(РейтингПомещения),
	| СУММА(КоличествоВсего)
	|ПО
	| Помещение";

	Запрос.Текст = ТекстЗапроса;

	Запрос.УстановитьПараметр("Помещение", Параметры.Помещение);
	Запрос.УстановитьПараметр("ПоВсемПомещениям", Не ЗначениеЗаполнено(Параметры.Помещение));
	Запрос.УстановитьПараметр("ТаблицаНоменклатурыДляЗапроса", ТаблицаНоменклатурыДляЗапроса);
	Запрос.УстановитьПараметр("ТекущаяДата", ТекущаяДата);

	МассивРезультатов = Запрос.ВыполнитьПакет();

	ДеревоТоваров = МассивРезультатов[3].Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам); // ДеревоЗначений

	ДеревоПоПомещениям = МассивРезультатов[4].Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);

	ТаблицаОшибок = ТаблицаНоменклатурыДляЗапроса.СкопироватьКолонки("Склад, Номенклатура, Характеристика, Назначение, Серия, Количество");
	ТаблицаОшибок.Колонки.Добавить("ЕдиницаИзмерения", Новый ОписаниеТипов("СправочникСсылка.УпаковкиЕдиницыИзмерения"));

	ПомещениеЗонаОтгрузки = Новый Соответствие;

	Для Каждого УровеньОтгрузкаПоЗаданиюНаПеревозку Из ДеревоТоваров.Строки Цикл	
		Для Каждого УровеньЗаданиеНаПеревозку Из УровеньОтгрузкаПоЗаданиюНаПеревозку.Строки Цикл

			Если ЗначениеЗаполнено(Параметры.ЗаданиеНаПеревозку) Тогда
				ЗаданиеНаПеревозку = Параметры.ЗаданиеНаПеревозку;
			Иначе
				ЗаданиеНаПеревозку = УровеньЗаданиеНаПеревозку.ЗаданиеНаПеревозку;
			КонецЕсли;

			Для Каждого УровеньСклад Из УровеньЗаданиеНаПеревозку.Строки Цикл 

				Для Каждого УровеньПолучатель Из УровеньСклад.Строки Цикл

					Для Каждого УровеньРаспоряжение Из УровеньПолучатель.Строки Цикл

						Для Каждого УровеньДатаОтгрузки Из УровеньРаспоряжение.Строки Цикл

							Для Каждого УровеньСкладскаяОперация Из УровеньДатаОтгрузки.Строки Цикл

								ТаблицаНоменклатуры = УровеньСкладскаяОперация.Строки;

								ВсеКоличествоОформленоПоПомещению = Ложь;
								// Если нет остатков вообще по помещениям
								Если ДеревоПоПомещениям.Строки.Количество() = 0 Тогда
									Для Каждого Строка Из ТаблицаНоменклатуры Цикл
										СтрокаТаблицыОшибок = ТаблицаОшибок.Добавить();
										ЗаполнитьЗначенияСвойств(СтрокаТаблицыОшибок,Строка);
									КонецЦикла;	
									Прервать;
								КонецЕсли;

								ИспользоватьПомещения = СкладыСервер.ИспользоватьСкладскиеПомещения(УровеньСкладскаяОперация.Склад, УровеньСкладскаяОперация.ДатаОтгрузки, Истина);
								МассивЛучшихПомещений = Новый Массив;

								// 1. Проводим ранжирование помещений по сумме степени собранности каждой позиции
								// 2. По лучшему помещению создаем документ
								// 3. Из количества к отгрузке вычитаем уже попавшее в документ количество
								// 4. Для всех помещений, кроме лучшего, проводим ранжирование (т.к. количество в каждой позиции могло уменьшится,
								//    рейтинг помещения мог поменяться).

								Пока ТаблицаНоменклатуры.Количество() > 0 Цикл

									// Указанный в строках по помещениям рейтинг нужно очищать:
									// - когда перешли к новому распоряжению
									// - когда выбрали товары лучшего помещения и нужно перерасчитать рейтинг оставшихся помещений.
									НужноОбнулитьРейтингСтрокПоПомещениям = Истина;     

									// Если нет остатков вообще по помещениям
									Если ДеревоПоПомещениям.Строки.Количество() = 0 Тогда
										Прервать;
									КонецЕсли;

									КоличествоВсего = ТаблицаНоменклатуры.Итог("Количество");
									ПомещенияОрдера = Новый Соответствие;
									ПомещенияТовары = Новый Соответствие;

									Для каждого СтрТабл Из ТаблицаНоменклатуры Цикл

										Для каждого СтрПомещение Из ДеревоПоПомещениям.Строки  Цикл 

											Если ИспользоватьПомещения И Не ЗначениеЗаполнено(СтрПомещение.Помещение) Тогда
												Продолжить;
											КонецЕсли;

											Если НужноОбнулитьРейтингСтрокПоПомещениям Тогда
												СтрПомещение.КоличествоВсего  = 0;
												СтрПомещение.РейтингПомещения = 0;
											КонецЕсли;

											Если МассивЛучшихПомещений.Найти(СтрПомещение.Помещение) <> Неопределено Тогда
												Продолжить;
											КонецЕсли;

											ДокументОбъект = ПомещенияОрдера.Получить(СтрПомещение.Помещение);
											ТоварыВОрдере = ПомещенияТовары.Получить(СтрПомещение.Помещение);

											Если ДокументОбъект = Неопределено Тогда

												ПараметрыПоискаРасходногоОрдера = Новый Структура;
												ПараметрыПоискаРасходногоОрдера.Вставить("Склад",					УровеньСкладскаяОперация.Склад);
												ПараметрыПоискаРасходногоОрдера.Вставить("Помещение",				СтрПомещение.Помещение);
												ПараметрыПоискаРасходногоОрдера.Вставить("ЗонаОтгрузки",			Параметры.ЗонаОтгрузки);
												ПараметрыПоискаРасходногоОрдера.Вставить("Получатель",				УровеньСкладскаяОперация.Получатель);
												ПараметрыПоискаРасходногоОрдера.Вставить("РаспоряжениеГруппировка",	УровеньСкладскаяОперация.РаспоряжениеГруппировка);
												ПараметрыПоискаРасходногоОрдера.Вставить("РаспоряженияНаОтгрузку",	Параметры.РаспоряженияНаОтгрузку);
												ПараметрыПоискаРасходногоОрдера.Вставить("СкладскаяОперация",		УровеньСкладскаяОперация.СкладскаяОперация);
												ПараметрыПоискаРасходногоОрдера.Вставить("ДатаОтгрузки",			УровеньСкладскаяОперация.ДатаОтгрузки);
												ПараметрыПоискаРасходногоОрдера.Вставить("ТекущаяДата",				ТекущаяДата); 
												ПараметрыПоискаРасходногоОрдера.Вставить("ЗаданиеНаПеревозку",		ЗаданиеНаПеревозку);
												ПараметрыПоискаРасходногоОрдера.Вставить("ОтгрузкаПоЗаданиюНаПеревозку", УровеньСкладскаяОперация.ОтгрузкаПоЗаданиюНаПеревозку);

												Если Параметры.Свойство("СозданныеРасходныеОрдера") Тогда
													Строка = Параметры.СозданныеРасходныеОрдера.Найти(Ложь, "Использован");
													Если Не Строка = неопределено Тогда
														ДокументОбъект = ЗаполнитьРасходныйОрдерНаТовары(ПараметрыПоискаРасходногоОрдера, Строка.ДокументОбъект);
														Строка.Использован = Истина;													
													Иначе 
														ДокументОбъект = ЗаполнитьРасходныйОрдерНаТовары(ПараметрыПоискаРасходногоОрдера, Документы.РасходныйОрдерНаТовары.СоздатьДокумент());
													КонецЕсли;
												Иначе
													ДокументОбъект = ПолучитьОбъектОрдер(ПараметрыПоискаРасходногоОрдера);
												КонецЕсли;

												ПомещенияОрдера.Вставить(СтрПомещение.Помещение, ДокументОбъект);

												ТоварыВОрдере = ДокументОбъект.ТоварыПоРаспоряжениям.ВыгрузитьКолонки();
												ПомещенияТовары.Вставить(СтрПомещение.Помещение, ТоварыВОрдере);

											КонецЕсли;

											СтруктураОтбора = Новый Структура("Номенклатура,Характеристика,Серия,Назначение");
											ЗаполнитьЗначенияСвойств(СтруктураОтбора,СтрТабл);

											МассивСтрок = СтрПомещение.Строки.НайтиСтроки(СтруктураОтбора);

											Если МассивСтрок.Количество() = 0 Тогда
												Продолжить;
											КонецЕсли;

											Номенклатура = МассивСтрок[0]; 

											КоличествоВДокумент = Мин(Номенклатура.СвободныйОстатокВБазовых - Номенклатура.КоличествоВБазовыхИзрасходовано, СтрТабл.Количество);

											Если КоличествоВДокумент = 0 Тогда
												Продолжить;
											КонецЕсли;	

											НоваяСтрокаТовара = ДокументОбъект.ТоварыПоРаспоряжениям.Добавить();
											НоваяСтрокаТовара.Распоряжение      = СтрТабл.Распоряжение;
											НоваяСтрокаТовара.Номенклатура      = СтрТабл.Номенклатура;
											НоваяСтрокаТовара.Характеристика    = СтрТабл.Характеристика;
											НоваяСтрокаТовара.Назначение      = СтрТабл.Назначение;
											НоваяСтрокаТовара.Серия           = СтрТабл.Серия;
											НоваяСтрокаТовара.Количество      = КоличествоВДокумент;

											НоваяСтрокаТоварыВОрдере = ТоварыВОрдере.Добавить();
											ЗаполнитьЗначенияСвойств(НоваяСтрокаТоварыВОрдере,НоваяСтрокаТовара);

											// Сразу не уменьшаем свободный остаток, т.к. если помещение не будет лучшим, брать из него не будем.
											Номенклатура.КоличествоВБазовыхИзрасходовано = Номенклатура.КоличествоВБазовыхИзрасходовано + КоличествоВДокумент;

											СтрПомещение.КоличествоВсего = СтрПомещение.КоличествоВсего + КоличествоВДокумент; 

											// СтрТабл.Количество не равно нулю: проверяется в запросе и при уменьшении количества в таблице ТаблицаНоменклатуры.
											СтрПомещение.РейтингПомещения = СтрПомещение.РейтингПомещения + КоличествоВДокумент/СтрТабл.Количество;       

										КонецЦикла;

										НужноОбнулитьРейтингСтрокПоПомещениям = Ложь;

									КонецЦикла;

									ДеревоПоПомещениям.Строки.Сортировать("РейтингПомещения УБЫВ, КоличествоВсего УБЫВ");

									ЛучшееПомещение = ДеревоПоПомещениям.Строки[0];

									Если ИспользоватьПомещения
										И Не ЗначениеЗаполнено(ЛучшееПомещение.Помещение) Тогда
										Если ДеревоПоПомещениям.Строки.Количество()>1 Тогда
											ЛучшееПомещение = ДеревоПоПомещениям.Строки[1];
										Иначе
											Прервать;
										КонецЕсли;
									КонецЕсли;

									// Если в помещениях нет остатка для этого распоряжения
									Если ЛучшееПомещение.РейтингПомещения = 0 Тогда
										Прервать;
									КонецЕсли;

									ДокументОбъект = ПомещенияОрдера[ЛучшееПомещение.Помещение];

									Если Параметры.Свойство("СозданныеРасходныеОрдера") Тогда
										// Очищаем товары в ордерах по нелучшим помещениям
										Для каждого Стр Из ДеревоПоПомещениям.Строки Цикл
											Если НЕ Стр = ЛучшееПомещение Тогда 
												Строка=Параметры.СозданныеРасходныеОрдера.найти(ПомещенияОрдера[Стр.Помещение],"ДокументОбъект");
												Если НЕ Строка = неопределено Тогда
													Строка.Использован = Ложь;
													Строка.ДокументОбъект.ТоварыПоРаспоряжениям.Очистить();
												КонецЕсли;
											КонецЕсли;
										КонецЦикла;
									КонецЕсли;

									ТоварыВОрдере = ПомещенияТовары[ЛучшееПомещение.Помещение];

									Если ДокументОбъект.ТоварыПоРаспоряжениям.Количество() > 0 Тогда    
										ОбъектНовый = Не ДокументОбъект.Проведен;
										#Вставка
										// #wortmann {
										// #Автоматическое заполнение табличной части документа Расходный ордер 
										// Передаем список Упаковочных листов
										// Галфинд Volkov 2022/09/10
										Если Параметры.Свойство("гф_УпаковочныйЛист") Тогда
											
											ДокументОбъект.ДополнительныеСвойства.Вставить("гф_УпаковочныйЛист", Параметры.гф_УпаковочныйЛист);
											
											Для Каждого УП Из Параметры.гф_УпаковочныйЛист Цикл
												ДокументОбъект.гф_СуммаНоменклатуры = ДокументОбъект.гф_СуммаНоменклатуры +
													(УП.ЦенаПары * УП.КоличествоПарОбуви * УП.Скидка / 100 - УП.ЦенаПары * УП.КоличествоПарОбуви) * (-1);
											КонецЦикла;
											
										ИначеЕсли Параметры.Свойство("гф_Товары") Тогда
											
											Для Каждого Товар Из Параметры.гф_Товары Цикл
												ДокументОбъект.гф_СуммаНоменклатуры = ДокументОбъект.гф_СуммаНоменклатуры +
													(Товар.Цена * Товар.КоличествоОстаток * Товар.Скидка / 100 - Товар.Цена * Товар.КоличествоОстаток) * (-1);
											КонецЦикла;
											
										КонецЕсли;
										
										Если Параметры.Свойство("гф_ОтгрузкаПеремещением") И Параметры.гф_ОтгрузкаПеремещением Тогда
											ДокументОбъект.СкладскаяОперация = Перечисления.СкладскиеОперации.ОтгрузкаПоПеремещению;
										КонецЕсли;
										
										Если Параметры.Свойство("гф_Заказ") Тогда
											ДокументОбъект.ДополнительныеСвойства.Вставить("гф_Заказ", Параметры.гф_Заказ);
										КонецЕсли;	
										// } #wortmann
										#КонецВставки
										Если Не ЗаписатьОбъектОрдер(ДокументОбъект,Параметры.ФоновоеЗадание) Тогда
											ЕстьОшибка = Истина;
										КонецЕсли;

										Если ДокументОбъект.Проведен И Не ЕстьОшибка Тогда
											Если ОбъектНовый Тогда
												ОформленныеОрдераСтрока = ОформленныеОрдера.Добавить();
												ЗаполнитьЗначенияСвойств(ОформленныеОрдераСтрока, ДокументОбъект);
												ОформленныеОрдераСтрока.РасходныйОрдер = ДокументОбъект.Ссылка;
												ОформленныеОрдераСтрока.Действие = НСтр("ru = 'Создан новый';
												|en = 'New is created'");
											Иначе
												Если ОформленныеОрдера.Найти(ДокументОбъект.Ссылка, "РасходныйОрдер") = Неопределено Тогда
													ОформленныеОрдераСтрока = ОформленныеОрдера.Добавить();
													ЗаполнитьЗначенияСвойств(ОформленныеОрдераСтрока, ДокументОбъект);
													ОформленныеОрдераСтрока.РасходныйОрдер = ДокументОбъект.Ссылка;
													ОформленныеОрдераСтрока.Действие = НСтр("ru = 'Переоформлен';
													|en = 'Reregister'");
												КонецЕсли;
											КонецЕсли;
										КонецЕсли;
										#Вставка
										// #wortmann {
										// #Автоматическое заполнение табличной части документа Расходный ордер 
										// Передаем список Упаковочных листов
										// Галфинд Volkov 2022/09/10
										Если ДокументОбъект.Проведен И Не ЕстьОшибка Тогда
											
											Если Параметры.Свойство("гф_СоздатьОрдера") Тогда
												Параметры.гф_СоздатьОрдера = Истина;
											КонецЕсли;
										
											Если Параметры.Свойство("гф_УпаковочныйЛист") Тогда
												Для Каждого УП Из Параметры.гф_УпаковочныйЛист Цикл
													гф_ТекущийОрдерОбъект = ДокументОбъект.Ссылка.ПолучитьОбъект();
													гф_УпаковочныйЛистОбъект = УП.УпаковочныйЛист.ПолучитьОбъект();
													гф_УпаковочныйЛистОбъект.гф_ТекущийОрдер = гф_ТекущийОрдерОбъект.Ссылка;
													
													Если ЗначениеЗаполнено(гф_УпаковочныйЛистОбъект.гф_ТекущийОрдер)
														И Не ПустаяСтрока(гф_ТекущийОрдерОбъект.ВерсияДанных) Тогда
														
														// Очистим колонку с кодом строки перед новым заполнением 
														ТабЗнач = гф_УпаковочныйЛистОбъект.Товары.Выгрузить();
														ТабЗнач.ЗаполнитьЗначения(0, "гф_КодСтроки");
														ТабЗнач.ЗаполнитьЗначения("", "гф_КодСтрокиДополнительныеСведения");
														гф_УпаковочныйЛистОбъект.Товары.Загрузить(ТабЗнач);
														
														Для Каждого СтрокаУпаковочныйЛистНоменклатура Из гф_УпаковочныйЛистОбъект.Товары Цикл
															
															Для Каждого СтрокаСписокКодовСтроки Из УП.СписокКодовСтроки Цикл
																
																Если СтрокаСписокКодовСтроки.Номенклатура = СтрокаУпаковочныйЛистНоменклатура.Номенклатура
																	И СтрокаСписокКодовСтроки.Характеристика = СтрокаУпаковочныйЛистНоменклатура.Характеристика Тогда
																	
																	// Для упаковочных листов с пересортом товара в заказе есть отдельные строки для таких позиций номенклатуры,
																	// поэтому запишим коды таких строк в отдельный реквизит, что бы при создании документа реализации эти строки найти
																	Если Не СтрокаУпаковочныйЛистНоменклатура.гф_КодСтроки > 0 Тогда
																		СтрокаУпаковочныйЛистНоменклатура.гф_КодСтроки = СтрокаСписокКодовСтроки.КодСтроки;
																	Иначе
																		Если ЗначениеЗаполнено(СтрокаУпаковочныйЛистНоменклатура.гф_КодСтрокиДополнительныеСведения) Тогда
																			СтрокаУпаковочныйЛистНоменклатура.гф_КодСтрокиДополнительныеСведения = СтрЗаменить(СтрокаУпаковочныйЛистНоменклатура.гф_КодСтрокиДополнительныеСведения + "," +СтрокаСписокКодовСтроки.КодСтроки, Символы.НПП, "");
																		
																		Иначе
																			СтрокаУпаковочныйЛистНоменклатура.гф_КодСтрокиДополнительныеСведения = СтрЗаменить(СтрокаСписокКодовСтроки.КодСтроки, Символы.НПП, "");
																		КонецЕсли;
																	КонецЕсли;
																	
																КонецЕсли;
																
															КонецЦикла;
															
														КонецЦикла;
														
														гф_Агрегация = гф_УпаковочныйЛистОбъект.гф_Агрегация;
														
														гф_КодМаркировки = гф_Агрегация.ПолучитьОбъект();
														гф_КодМаркировки.гф_Автодействие = Перечисления.гф_АвтодействияКМ.Подготовлен;
														
														Попытка
															гф_КодМаркировки.Записать();
														Исключение
															ТекстСообщения = СтрШаблон(НСтр("ru = 'Не удалось внести изменения в элемент справочника ""Штрихкоды упаковок товаров"" ""%1"", расходный ордер не сформирован.'"),
															гф_Агрегация);
															ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
															
															ЗаписьЖурналаРегистрации(НСтр("ru = 'Запись в элемент справочника ""Штрихкоды упаковок товаров""'"), УровеньЖурналаРегистрации.Ошибка,,,
															ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
														КонецПопытки;
													
													КонецЕсли;
													
													Попытка
														гф_УпаковочныйЛистОбъект.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
													Исключение
														ТекстСообщения = СтрШаблон(НСтр("ru = 'Не удалось внести изменения в ""%1"", расходный ордер не сформирован.'"),
														гф_УпаковочныйЛистОбъект.Ссылка);
														ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
														
														ЗаписьЖурналаРегистрации(НСтр("ru = 'Запись в ""Упаковочный лист""'"), УровеньЖурналаРегистрации.Ошибка,,,
														ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
													КонецПопытки;
													
												КонецЦикла;
											КонецЕсли;	
											
										КонецЕсли;
										// } #wortmann
										#КонецВставки

										ОрдерЗаписан = Истина;                                  
									КонецЕсли;

									// Если не последняя строка по получателю, складу, дате отгрузки и скл. операции,
									// то в лучшем помещении надо уменьшить свободный остаток.
									Если ДеревоТоваров.Строки.Количество() - 1 > ДеревоТоваров.Строки.Индекс(УровеньСкладскаяОперация) Тогда

										// Помещение выбрано - можно уменьшать свободный остаток

										Для Каждого СтрТовары Из ТоварыВОрдере Цикл 
											ОтборСтрок = Новый Структура("Склад,Номенклатура,Характеристика,Назначение,Серия");
											ЗаполнитьЗначенияСвойств(ОтборСтрок,СтрТовары);
											ОтборСтрок.Склад = УровеньСкладскаяОперация.Склад;
											СтрокаНоменклатуры = ЛучшееПомещение.Строки.НайтиСтроки(ОтборСтрок);
											Если СтрокаНоменклатуры.Количество() > 0 Тогда
												Номенклатура = СтрокаНоменклатуры[0];
												Номенклатура.СвободныйОстатокВБазовых = Номенклатура.СвободныйОстатокВБазовых - Номенклатура.КоличествоВБазовыхИзрасходовано;
												Номенклатура.КоличествоВБазовыхИзрасходовано = 0;

												// Чтобы в дальнейшем быстрее искалось, удалим пустую строку
												Если Номенклатура.СвободныйОстатокВБазовых = 0 Тогда 
													ЛучшееПомещение.Строки.Удалить(Номенклатура);
												КонецЕсли;

											КонецЕсли;

										КонецЦикла;

									КонецЕсли;

									// Очистка КоличествоВБазовыхИзрасходовано
									Для Каждого СтрокиПоПомещениям Из ДеревоПоПомещениям.Строки Цикл
										Для Каждого Строки Из СтрокиПоПомещениям.Строки Цикл
											Строки.КоличествоВБазовыхИзрасходовано = 0;
										КонецЦикла;
										Если ЛучшееПомещение <> СтрокиПоПомещениям Тогда
											СтрокиПоПомещениям.КоличествоВсего  = 0;
											СтрокиПоПомещениям.РейтингПомещения = 0;
										КонецЕсли;
									КонецЦикла;

									Если ЛучшееПомещение.КоличествоВсего = КоличествоВсего Тогда
										ВсеКоличествоОформленоПоПомещению = Истина;
									КонецЕсли;	

									Если ЛучшееПомещение.КоличествоВсего = КоличествоВсего
										Или ЛучшееПомещение.КоличествоВсего = 0
										Или МассивЛучшихПомещений.Количество() = ДеревоПоПомещениям.Строки.Количество() Тогда
										// Если собрали полностью,
										// или не собрали вообще прерываем цикл по строкам распоряжения
										// или перебрали все помещения.
										ЛучшееПомещение.КоличествоВсего   = 0;
										ЛучшееПомещение.РейтингПомещения  = 0;
										Прервать;

									Иначе
										ЛучшееПомещение.КоличествоВсего   = 0;
										ЛучшееПомещение.РейтингПомещения  = 0;

										ТоварыВОрдере.Свернуть("Распоряжение, Номенклатура, Характеристика, Назначение, Серия" , "Количество");

										Для каждого СтрТабл Из ТоварыВОрдере Цикл

											СтруктураОтбора = Новый Структура("Распоряжение,Номенклатура,Характеристика,Назначение,Серия");
											ЗаполнитьЗначенияСвойств(СтруктураОтбора,СтрТабл);

											СтрокиТаблицыНоменклатуры = ТаблицаНоменклатуры.НайтиСтроки(СтруктураОтбора);
											Если СтрокиТаблицыНоменклатуры.Количество() = 0 Тогда
												Продолжить;
											КонецЕсли;  
											СтрокаТаблицыНоменклатуры = СтрокиТаблицыНоменклатуры[0];

											СтрокаТаблицыНоменклатуры.Количество = СтрокаТаблицыНоменклатуры.Количество - СтрТабл.Количество;

											Если СтрокаТаблицыНоменклатуры.Количество <= СтрокаТаблицыНоменклатуры.ДопустимоеОтклонение Тогда
												ТаблицаНоменклатуры.Удалить(СтрокаТаблицыНоменклатуры);
											КонецЕсли;

										КонецЦикла;

									КонецЕсли;

									МассивЛучшихПомещений.Добавить(ЛучшееПомещение.Помещение);

									// Если в помещении нет товаров, его можно удалить из дерева помещений
									Если ЛучшееПомещение.Строки.Количество() = 0 Тогда
										ДеревоПоПомещениям.Строки.Удалить(ЛучшееПомещение);
									КонецЕсли;

								КонецЦикла;

								Если Не ВсеКоличествоОформленоПоПомещению Тогда
									Для Каждого Строка Из ТаблицаНоменклатуры Цикл
										СтрокаТаблицыОшибок = ТаблицаОшибок.Добавить();
										ЗаполнитьЗначенияСвойств(СтрокаТаблицыОшибок,Строка);
									КонецЦикла;
								КонецЕсли 	

							КонецЦикла;
						КонецЦикла;
					КонецЦикла;
				КонецЦикла;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;

	Если ТаблицаОшибок.Количество() = 0 И Не ОрдерЗаписан Тогда

		ЕстьОшибка = Истина;
		Если ЗначениеЗаполнено(Параметры.Получатель) Тогда 		
			ТекстСообщения = НСтр("ru = 'Расходные ордера по распоряжениям на отгрузку для получателя ""%Получатель%"" и склада ""%Склад%"" не созданы. Возможные причины:
			|- все товары уже собираются (собраны)%СначалаНакладные%%НачинатьОтгрузкуПослеФормированияЗаданияНаПеревозку%.';
			|en = 'Goods issue notes under shipment references for the ""%Получатель%"" recipient and the ""%Склад%"" warehouse are not created. Possible reasons:
			|- All goods are already being assembled (have been assembled) %СначалаНакладные%%НачинатьОтгрузкуПослеФормированияЗаданияНаПеревозку%.'");
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Получатель%", Строка(Параметры.Получатель));
		Иначе
			ТекстСообщения = НСтр("ru = 'Расходные ордера по распоряжениям на отгрузку для склада ""%Склад%"" не созданы. Возможные причины:
			|- все товары уже собираются (собраны)%СначалаНакладные%%НачинатьОтгрузкуПослеФормированияЗаданияНаПеревозку%.';
			|en = 'Goods issue notes under shipment references for the ""%Склад%"" warehouse are not created. Possible reasons:
			|- All goods are already being assembled (have been assembled) %СначалаНакладные%%НачинатьОтгрузкуПослеФормированияЗаданияНаПеревозку%.'");
		КонецЕсли;
		ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Склад%", Строка(Параметры.Склад));

		Если СначалаНакладные Тогда					   
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СначалаНакладные%", НСтр("ru = ';
			|- не оформлены накладные';
			|en = ';
			|- invoices are not created'"));
		Иначе
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%СначалаНакладные%", "");
		КонецЕсли; 
		Если НачинатьОтгрузкуПослеФормированияЗаданияНаПеревозку Тогда					   
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%НачинатьОтгрузкуПослеФормированияЗаданияНаПеревозку%", НСтр("ru = ';
			|- не оформлены задания на перевозку';
			|en = '
			|- Delivery orders are not registered'"));
		Иначе
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%НачинатьОтгрузкуПослеФормированияЗаданияНаПеревозку%", "");
		КонецЕсли;  
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
	ИначеЕсли ТаблицаОшибок.Количество() > 0 Тогда	

		ЕстьОшибка = Истина;

		ШаблонСообщения = НСтр("ru = 'Номенклатура %НоменклатураХарактеристика% %Назначение%
		|Недостаточно для отгрузки на складе ""%Склад%"" %Количество% %Единица%';
		|en = 'Item %НоменклатураХарактеристика% %Назначение%
		|Not enough for shipment in warehouse %Склад% %Количество% %Единица%'");

		ТаблицаОшибок.Свернуть("Склад, Номенклатура, Характеристика, Назначение, Серия, ЕдиницаИзмерения","Количество");
		Для Каждого СтрокаОшибка Из ТаблицаОшибок Цикл

			ТекстСообщения = СтрЗаменить(ШаблонСообщения, "%НоменклатураХарактеристика%",
			НоменклатураКлиентСервер.ПредставлениеНоменклатуры(СтрокаОшибка.Номенклатура,
			СтрокаОшибка.Характеристика,
			СтрокаОшибка.Серия));
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Склад%", Строка(СтрокаОшибка.Склад));		
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Количество%", Строка(СтрокаОшибка.Количество));
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Единица%",    Строка(СтрокаОшибка.ЕдиницаИзмерения));
			Назначение = ?(ЗначениеЗаполнено(СтрокаОшибка.Назначение), "(" + Строка(СтрокаОшибка.Назначение) + ")", "");
			ТекстСообщения = СтрЗаменить(ТекстСообщения, "%Назначение%", Назначение);

			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);

		КонецЦикла;

	КонецЕсли;

	Возврат Новый Структура("ОформленныеОрдера, ЕстьОшибка", ОформленныеОрдера,ЕстьОшибка);

КонецФункции
