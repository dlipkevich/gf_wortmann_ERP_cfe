﻿
#Область СведенияОВнешнейОбработке

Функция СведенияОВнешнейОбработке() Экспорт
	
	РегистрационныеДанные = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке(СтандартныеПодсистемыСервер.ВерсияБиблиотеки());
	РегистрационныеДанные.Вставить("Вид", ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительнаяОбработка());
	РегистрационныеДанные.Вставить("Наименование", "Корректировка назначений");
	РегистрационныеДанные.Вставить("Версия", Формат(ТекущаяДатаСеанса(), "ДФ=yyyy-MM-dd"));
	РегистрационныеДанные.Вставить("Информация", "");
	РегистрационныеДанные.Вставить("БезопасныйРежим", Ложь);
	
	// Добавим команду в таблицу
	Если РегистрационныеДанные.Свойство("Команды") Тогда 
		
		ДобавитьКоманду(
			РегистрационныеДанные.Команды, 
			"Корректировка назначений", 
			"гф_КорректировкаНазначений", 
			ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы()
		);
			
		ДобавитьКоманду(
			РегистрационныеДанные.Команды, 
			"Корректировка назначений (автоматически)", 
			"гф_КорректировкаНазначенийАвтоматически", 
			ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыВызовСерверногоМетода(), 
			Истина
		);
				
	Иначе
		ВызватьИсключение НСтр("ru = 'Не соответствующая версия БСП.'");
	КонецЕсли;
	
	Возврат РегистрационныеДанные;
	
КонецФункции

// Добавляет команду в таблицу команд по переданному описанию.
// 
// Параметры:
//   ТаблицаКоманд - ТаблицаЗначений - состав полей см. в функции ПолучитьТаблицуКоманд
//   Представление - Строка - описание печатной формы для пользователя
//   Идентификатор - Строка - идентификатор макета
//   Использование - Строка - параметр вызова обработки
//     Возможные варианты:
//       ОткрытиеФормы - в этом случае в колонке идентификатор должно быть указано имя формы, которое должна будет открыть система
//       ВызовКлиентскогоМетода - вызвать клиентскую экспортную процедуру из модуля формы обработки
//       ВызовСерверногоМетода - вызвать серверную экспортную процедуру из модуля объекта обработки
//   ПоказыватьОповещение - Булево - указывает, необходимо ли показывать оповещение при начале и завершению работы обработки
//     Не имеет смысла при открытии формы
//   Модификатор - Строка - для печатной формы должен содержать строку ПечатьMXL
//
Процедура ДобавитьКоманду(ТаблицаКоманд, Представление, Идентификатор, Использование = "ОткрытиеФормы", ПоказыватьОповещение = Ложь, Модификатор = "ПечатьMXL")
	
	НоваяКоманда = ТаблицаКоманд.Добавить();
	
	НоваяКоманда.Представление = Представление;
	НоваяКоманда.Идентификатор = Идентификатор;
	НоваяКоманда.Использование = Использование;
	НоваяКоманда.ПоказыватьОповещение = ПоказыватьОповещение;
	НоваяКоманда.Модификатор = Модификатор;
	
КонецПроцедуры

#КонецОбласти

Процедура ВыполнитьКоманду(ИдентификаторКоманды, ПараметрыВыполненияКоманды = Неопределено) Экспорт
	
	Если ИдентификаторКоманды = "гф_КорректировкаНазначенийАвтоматически" Тогда 
				
		//ЗаписьЖурналаРегистрации(
		//	НСтр("ru = ''"),
		//	УровеньЖурналаРегистрации.Информация,,, "Начало автоматического выполнения.");
			
		ЗаполнитьСвойствоПроверкаПТУ();
		
		ДатаОкончания = ТекущаяДатаСеанса();
		ДатаНачала = ДатаОкончания - 7*86400; // 7 дней
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	гф_ГлобальныеЗначенияСписок.Значение.гф_Организация КАК Организация,
			|	гф_ГлобальныеЗначенияСписок.Значение КАК Склад
			|ИЗ
			|	ПланВидовХарактеристик.гф_ГлобальныеЗначения.Список КАК гф_ГлобальныеЗначенияСписок
			|ГДЕ
			|	гф_ГлобальныеЗначенияСписок.Ссылка.Ключ = &Ключ";
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Организация = ВыборкаДетальныеЗаписи.Организация;
			Склад = ВыборкаДетальныеЗаписи.Склад;
			ЗаполнитьНаСервере();
			ВыполнитьОбработкуНаСервере();
		КонецЦикла;
	
		//ЗаписьЖурналаРегистрации(
		//	НСтр("ru = ''"),
		//	УровеньЖурналаРегистрации.Информация,,, "Успешное завершение автоматического выполнения.");
			
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыполнитьОбработкуНаСервере() Экспорт
	
	// 1. Создание документа «Корректировка назначения товаров» (для корректной работы с движениями по регистрам)
	
	ЗаказыКОбработке = ДанныеДляОтображения.Выгрузить(Новый Структура("Отметка", Истина), "ЗаказКлиента");
	ЗаказыКОбработке.Свернуть("ЗаказКлиента");
	
	Для Каждого СтрокаЗаказа Из ЗаказыКОбработке Цикл
		
		ДанныеКОбработке = Данные.Выгрузить(Новый Структура("ЗаказКлиента", СтрокаЗаказа.ЗаказКлиента));
		
		ДокументОбъект = Документы.КорректировкаНазначенияТоваров.СоздатьДокумент();
		
		ДокументОбъект.Дата = ТекущаяДатаСеанса();
		ДокументОбъект.ВидОперации = Перечисления.ВидыОперацийКорректировкиНазначения.РезервироватьИКорректировать;
		ДокументОбъект.Организация = Организация;
		НазначениеЗаказа = Документы.КорректировкаНазначенияТоваров.НазначениеЗаказа(СтрокаЗаказа.ЗаказКлиента);
		ДокументОбъект.Назначение = НазначениеЗаказа;
		
		Для Каждого СтрокаТабличнойЧасти Из ДанныеКОбработке Цикл
			НоваяСтрока = ДокументОбъект.Товары.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТабличнойЧасти);
			НоваяСтрока.ИсходноеНазначение = СтрокаТабличнойЧасти.Назначение;
			НоваяСтрока.НовоеНазначение = ДокументОбъект.Назначение;
			НоваяСтрока.НовыйЗаказ = ДокументОбъект.Назначение.Заказ;
			НоваяСтрока.Склад = Склад;
			НоваяСтрока.гф_IDкороба = СтрокаТабличнойЧасти.УпаковочныйЛист;
		КонецЦикла;
		
		Автор = Пользователи.ТекущийПользователь();
		Ответственный = Пользователи.ТекущийПользователь();

		ДокументОбъект.Записать(РежимЗаписиДокумента.Запись);
		Попытка
			ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
		Исключение
			// Произошла ошибка при проведении документа.
			ШаблонТекстаИсключения = НСтр("ru = 'Невозможно провести документ %1.'");
			
			//ЗаписьЖурналаРегистрации(
			//	НСтр("ru = ''"),
			//	УровеньЖурналаРегистрации.Ошибка,,, СтрШаблон(ШаблонТекстаИсключения, ДокументОбъект.Ссылка, ОписаниеОшибки()));
			Сообщить(СтрШаблон(ШаблонТекстаИсключения, ДокументОбъект.Ссылка));
			
			// у ПТУ должен установиться реквизит «Проверка ПТУ» = Ошибка
			УстановитьДопРеквизитПриобретениеТоваровУслуг(СтрокаЗаказа.ЗаказКлиента);
			
			Продолжить;
		КонецПопытки;
		
		// 2. Корректировка назначений в Упаковочном листе (для корректной работы со складскими ордерами)
		УпаковочныеЛистыКОбработке = ДанныеКОбработке.Скопировать(Новый Структура("ЗаказКлиента", СтрокаЗаказа.ЗаказКлиента));
		УпаковочныеЛистыКОбработке.Свернуть("УпаковочныйЛист");
		
		Для Каждого СтрокаУпаковочногоЛиста Из УпаковочныеЛистыКОбработке Цикл
			
			ДокументОбъект = СтрокаУпаковочногоЛиста.УпаковочныйЛист.ПолучитьОбъект();
						
			Для Каждого СтрокаТабличнойЧасти Из ДокументОбъект.Товары Цикл
				СтрокаТабличнойЧасти.Назначение = НазначениеЗаказа;
			КонецЦикла;
			
			ДокументОбъект.Записать(РежимЗаписиДокумента.Запись);
			Попытка
				ДокументОбъект.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
			Исключение
				// Произошла ошибка при проведении документа.
				ШаблонТекстаИсключения = НСтр("ru = 'Невозможно провести документ %1.'");
				
				//ЗаписьЖурналаРегистрации(
				//	НСтр("ru = ''"),
				//	УровеньЖурналаРегистрации.Ошибка,,, СтрШаблон(ШаблонТекстаИсключения, ДокументОбъект.Ссылка, ОписаниеОшибки()));
				Сообщить(СтрШаблон(ШаблонТекстаИсключения, ДокументОбъект.Ссылка));
			КонецПопытки; 
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаполнитьНаСервере() Экспорт
	
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	УпаковочныйЛистТовары.Ссылка КАК УпаковочныйЛист,
		|	УпаковочныйЛистТовары.Ссылка.гф_СостояниеКороба КАК СостояниеКороба,
		|	УпаковочныйЛистТовары.Ссылка.гф_Заказ КАК ЗаказКлиента,
		|	УпаковочныйЛистТовары.Назначение КАК Назначение,
		|	УпаковочныйЛистТовары.Номенклатура КАК Номенклатура,
		|	УпаковочныйЛистТовары.Характеристика КАК Характеристика,
		|	УпаковочныйЛистТовары.Серия КАК Серия,
		|	УпаковочныйЛистТовары.Упаковка КАК Упаковка,
		|	УпаковочныйЛистТовары.КоличествоУпаковок КАК КоличествоУпаковок,
		|	УпаковочныйЛистТовары.Количество КАК Количество
		|ПОМЕСТИТЬ втДанные
		|ИЗ
		|	Документ.УпаковочныйЛист.Товары КАК УпаковочныйЛистТовары
		|ГДЕ
		|	УпаковочныйЛистТовары.Ссылка.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания
		|	И УпаковочныйЛистТовары.Ссылка.гф_Организация = &Организация
		|	И УпаковочныйЛистТовары.Ссылка.Проведен
		|	И НЕ УпаковочныйЛистТовары.Ссылка.ПометкаУдаления
		|	И ВЫБОР
		|			КОГДА &Поставка = ЗНАЧЕНИЕ(Документ.ПриобретениеТоваровУслуг.ПустаяСсылка)
		|				ТОГДА ИСТИНА
		|			ИНАЧЕ УпаковочныйЛистТовары.Ссылка.гф_Поставка = &Поставка
		|		КОНЕЦ
		|	И УпаковочныйЛистТовары.Назначение.Наименование = ""Техническое""
		|	И НЕ УпаковочныйЛистТовары.Ссылка.гф_СостояниеКороба В (&гф_СостояниеКороба)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	втДанные.УпаковочныйЛист КАК УпаковочныйЛист,
		|	втДанные.ЗаказКлиента КАК ЗаказКлиента,
		|	втДанные.Номенклатура КАК Номенклатура,
		|	втДанные.Характеристика КАК Характеристика,
		|	втДанные.Назначение КАК Назначение,
		|	втДанные.Серия КАК Серия,
		|	втДанные.Упаковка КАК Упаковка,
		|	втДанные.КоличествоУпаковок КАК КоличествоУпаковок,
		|	втДанные.Количество КАК Количество
		|ИЗ
		|	втДанные КАК втДанные
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ИСТИНА КАК Отметка,
		|	втДанные.УпаковочныйЛист КАК УпаковочныйЛист,
		|	втДанные.СостояниеКороба КАК СостояниеКороба,
		|	втДанные.ЗаказКлиента КАК ЗаказКлиента,
		|	втДанные.Назначение КАК Назначение
		|ИЗ
		|	втДанные КАК втДанные
		|
		|СГРУППИРОВАТЬ ПО
		|	втДанные.УпаковочныйЛист,
		|	втДанные.СостояниеКороба,
		|	втДанные.ЗаказКлиента,
		|	втДанные.Назначение";
	
	Запрос.УстановитьПараметр("ДатаНачала", 		ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", 		ДатаОкончания);
	Запрос.УстановитьПараметр("Организация", 		Организация);
	Запрос.УстановитьПараметр("Поставка", 			Поставка);
	гф_СостояниеКороба = Новый Массив;
	гф_СостояниеКороба.Добавить(Справочники.гф_СостянияКоробов.Сформирован);
	гф_СостояниеКороба.Добавить(Справочники.гф_СостянияКоробов.Реализован);
	гф_СостояниеКороба.Добавить(Справочники.гф_СостянияКоробов.Расформирован);
	Запрос.УстановитьПараметр("гф_СостояниеКороба", гф_СостояниеКороба);
	
	РезультатЗапроса = Запрос.ВыполнитьПакет();
	
	Данные.Загрузить(РезультатЗапроса[1].Выгрузить());
	ДанныеДляОтображения.Загрузить(РезультатЗапроса[2].Выгрузить());
	
КонецПроцедуры

Процедура ЗаполнитьСвойствоПроверкаПТУ() Экспорт 

	СвойствоПроверкаПТУ = Неопределено;
	
	СвойстваПТУ = УправлениеСвойствами.СвойстваОбъекта(Документы.ПриобретениеТоваровУслуг.ПустаяСсылка(), Истина, Ложь);
	
	Для Каждого СвойствоПТУ Из СвойстваПТУ Цикл
		Если СвойствоПТУ.Имя = "ПроверкаПТУ_549b4f1f2bf048ea96d7a5c25bb65706" Тогда
			СвойствоПроверкаПТУ = СвойствоПТУ;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если ЗначениеЗаполнено(СвойствоПроверкаПТУ) Тогда
		// определим значение Ошибка
		ЗначенияСвойстваПТУ = УправлениеСвойствамиСлужебный.ДополнительныеЗначенияСвойства(СвойствоПроверкаПТУ);
		Для Каждого ЗначениеСвойстваПТУ Из ЗначенияСвойстваПТУ Цикл 
			Если ЗначениеСвойстваПТУ.Наименование = "Ошибка " Тогда 
				ЗначениеПроверкаПТУ = ЗначениеСвойстваПТУ;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
	Иначе 
		Сообщить(НСтр("ru = 'Не удалось определить свойство ""Проверка ПТУ"".'"));
	КонецЕсли;
	
КонецПроцедуры

Процедура УстановитьДопРеквизитПриобретениеТоваровУслуг(ЗаказКлиента)
	
	Если НЕ ЗначениеЗаполнено(СвойствоПроверкаПТУ) Тогда 
		Сообщить(НСтр("ru = 'Не удалось определить свойство ""Проверка ПТУ"" по имени.'"));
		Возврат;
	КонецЕсли;
		
	Если НЕ ЗначениеЗаполнено(ЗначениеПроверкаПТУ) Тогда 
		Сообщить(НСтр("ru = 'Не удалось определить значение ""Ошибка"" свойства ""Проверка ПТУ"" по наименованию.'"));
		Возврат;
	КонецЕсли;
		
	ТаблицаДопРеквизитов = Новый ТаблицаЗначений;
	ТаблицаДопРеквизитов.Колонки.Добавить("Свойство", Новый ОписаниеТипов("ПланВидовХарактеристикСсылка.ДополнительныеРеквизитыИСведения"));
	ТаблицаДопРеквизитов.Колонки.Добавить("Значение");
	СтрокаДопРеквизитов = ТаблицаДопРеквизитов.Добавить();
	СтрокаДопРеквизитов.Свойство = СвойствоПроверкаПТУ;
	СтрокаДопРеквизитов.Значение = ЗначениеПроверкаПТУ;
	
	УпаковочныеЛистыСОшибкой = ДанныеДляОтображения.Выгрузить(Новый Структура("Отметка, ЗаказКлиента", Истина, ЗаказКлиента), "УпаковочныйЛист");
	УпаковочныеЛистыСОшибкой.Свернуть("УпаковочныйЛист");
	
	Для Каждого СтрокаУпаковочногоЛистаСОшибкой Из УпаковочныеЛистыСОшибкой Цикл
		ПТУКОбработке = СтрокаУпаковочногоЛистаСОшибкой.УпаковочныйЛист.гф_Поставка;
		Если ТипЗнч(ПТУКОбработке) = Тип("ДокументСсылка.ПриобретениеТоваровУслуг") Тогда
			УправлениеСвойствами.ЗаписатьСвойстваУОбъекта(ПТУКОбработке, ТаблицаДопРеквизитов);
		КонецЕсли;	
	КонецЦикла;
	
КонецПроцедуры

