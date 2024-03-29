﻿Функция СведенияОВнешнейОбработке() Экспорт
	
	ИмяОтчета = ЭтотОбъект.Метаданные().Имя; 
	Синоним = ЭтотОбъект.Метаданные().Синоним; 
	РегистрационныеДанные = Новый Структура;
	РегистрационныеДанные.Вставить("Вид",ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительныйОтчет());
	РегистрационныеДанные.Вставить("Наименование", Синоним);
	РегистрационныеДанные.Вставить("Версия", "1.0");
	РегистрационныеДанные.Вставить("БезопасныйРежим", Ложь);
	РегистрационныеДанные.Вставить("Информация", "Отчет "+Синоним);
	
	ТаблицаКоманд = ПолучитьТаблицуКоманд();
	
	// Добавим команду в таблицу
	ДобавитьКоманду(ТаблицаКоманд, Синоним, "СформироватьОтчет" , "ОткрытиеФормы", Истина, );
	
	// Сохраним таблицу команд в параметры регистрации обработки
	РегистрационныеДанные.Вставить("Команды", ТаблицаКоманд);
	
	Возврат РегистрационныеДанные;
	
КонецФункции

Функция ПолучитьТаблицуКоманд()
	
	// Создадим пустую таблицу команд и колонки в ней
	Команды = Новый ТаблицаЗначений;
	
	// Как будет выглядеть описание печатной формы для пользователя
	Команды.Колонки.Добавить("Представление", Новый ОписаниеТипов("Строка")); 
	
	// Имя нашего макета, что бы могли отличить вызванную команду в обработке печати
	Команды.Колонки.Добавить("Идентификатор", Новый ОписаниеТипов("Строка"));
	
	// Тут задается, как должна вызваться команда обработки
	// Возможные варианты:
	// - ОткрытиеФормы - в этом случае в колонке идентификатор должно быть указано имя формы, которое должна будет открыть система
	// - ВызовКлиентскогоМетода - вызвать клиентскую экспортную процедуру из модуля формы обработки
	// - ВызовСерверногоМетода - вызвать серверную экспортную процедуру из модуля объекта обработки
	Команды.Колонки.Добавить("Использование", Новый ОписаниеТипов("Строка"));
	
	// Следующий параметр указывает, необходимо ли показывать оповещение при начале и завершению работы обработки. Не имеет смысла при открытии формы
	Команды.Колонки.Добавить("ПоказыватьОповещение", Новый ОписаниеТипов("Булево"));
	
	// Для печатной формы должен содержать строку ПечатьMXL 
	Команды.Колонки.Добавить("Модификатор", Новый ОписаниеТипов("Строка"));
	Возврат Команды;
	
КонецФункции

Процедура ДобавитьКоманду(ТаблицаКоманд, Представление, Идентификатор, Использование = "ОткрытиеФормы", ПоказыватьОповещение = Ложь, Модификатор)
	
	// Добавляем команду в таблицу команд по переданному описанию.
	// Параметры и их значения можно посмотреть в функции ПолучитьТаблицуКоманд
	НоваяКоманда = ТаблицаКоманд.Добавить();
	НоваяКоманда.Представление = Представление;
	НоваяКоманда.Идентификатор = Идентификатор;
	НоваяКоманда.Использование = Использование;
	НоваяКоманда.ПоказыватьОповещение = ПоказыватьОповещение;
	НоваяКоманда.Модификатор = Модификатор;
	
КонецПроцедуры

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)  
	
	СтандартнаяОбработка=Ложь; 
	//++ СадомцевСА 18.10.2023 Применяю пользовательские настройки
	НастройкиКД = КомпоновщикНастроек.ПолучитьНастройки();
	КомпоновщикНастроек.ЗагрузитьНастройки(НастройкиКД);
	//--
    ДанныеРасшифровки= Новый ДанныеРасшифровкиКомпоновкиДанных;
	ПараметрыДанных = КомпоновщикНастроек.Настройки.ПараметрыДанных;
	Контрагенты = КомпоновщикНастроек.ПолучитьНастройки().ПараметрыДанных.Элементы.Найти("Контрагент").Значение;   
	ПараметрыДанных.УстановитьЗначениеПараметра("Контрагент", Контрагенты);
	Сезон = КомпоновщикНастроек.ПолучитьНастройки().ПараметрыДанных.Элементы.Найти("Сезон").Значение;  
	ОтборНастройки = КомпоновщикНастроек.Настройки.Отбор;
	ЭлементыПользовательскиеНастройки = КомпоновщикНастроек.ПользовательскиеНастройки.Элементы;  
	ОтборПоОрганизации = Неопределено;
	ПолеКомпоновкиОрганизация = Новый ПолеКомпоновкиДанных("Организация");  
	Для каждого ЭлементОтбора Из ОтборНастройки.Элементы Цикл
		Если ТипЗнч(ЭлементОтбора) = Тип("ЭлементОтбораКомпоновкиДанных")
			и ЭлементОтбора.ЛевоеЗначение = ПолеКомпоновкиОрганизация Тогда
			ОтборПоОрганизации = ЭлементОтбора;
			Прервать;
		КонецЕсли;	
	КонецЦикла; 
	Если ЭлементыПользовательскиеНастройки.Найти(ОтборПоОрганизации.ИдентификаторПользовательскойНастройки).Использование  Тогда
		Если ОтборПоОрганизации = Неопределено  Тогда
			ОтборПоОрганизации = ОтборНастройки.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
			ОтборПоОрганизации.ЛевоеЗначение = ПолеКомпоновкиОрганизация;
			ОтборПоОрганизации.РежимОтображения = РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Обычный; 
			ОтборПоОрганизации.ВидСравнения=ВидСравненияКомпоновкиДанных.Равно;
			ОтборПоОрганизации.ПравоеЗначение = ЭлементыПользовательскиеНастройки.Найти(ОтборПоОрганизации.ИдентификаторПользовательскойНастройки).ПравоеЗначение;	
		Иначе
			ОтборПоОрганизации.ПравоеЗначение = ЭлементыПользовательскиеНастройки.Найти(ОтборПоОрганизации.ИдентификаторПользовательскойНастройки).ПравоеЗначение;
			ОтборПоОрганизации.Использование=Истина;
		КонецЕсли;
	Иначе  
		ОтборПоОрганизации.Использование=Ложь;
	КонецЕсли;
	
	Если не Сезон.Пустая() Тогда
		пре = ПолучитьПредыдущиеСезоны(Сезон);
		ПараметрыДанных.УстановитьЗначениеПараметра("Сезон", Сезон);
		ПараметрыДанных.УстановитьЗначениеПараметра("Сезон1", пре.Сезон1);
		ПараметрыДанных.УстановитьЗначениеПараметра("Сезон2", пре.Сезон2);
		ПараметрыДанных.УстановитьЗначениеПараметра("Сезон3", пре.Сезон3);
		ПараметрыДанных.УстановитьЗначениеПараметра("Сезон4", пре.Сезон4);
		ПараметрыДанных.УстановитьЗначениеПараметра("ДатаОкончанияОтгрузок", Сезон.гф_ДатаОкончанияФормированияЗаказов);
		ПараметрыДанных.УстановитьЗначениеПараметра("ДатаОкончанияОтгрузок1", пре.Сезон1.гф_ДатаОкончанияФормированияЗаказов);
		ПараметрыДанных.УстановитьЗначениеПараметра("ДатаОкончанияОтгрузок2", пре.Сезон2.гф_ДатаОкончанияФормированияЗаказов);
		ПараметрыДанных.УстановитьЗначениеПараметра("ДатаОкончанияОтгрузок3", пре.Сезон3.гф_ДатаОкончанияФормированияЗаказов);
		ПараметрыДанных.УстановитьЗначениеПараметра("ДатаОкончанияОтгрузок4", пре.Сезон4.гф_ДатаОкончанияФормированияЗаказов);
	КонецЕсли;
	
	ПараметрыДанных.УстановитьЗначениеПараметра("ТекущаяДата", ТекущаяДатаСеанса());
	
	Если не ЗначениеЗаполнено(ДатаНачала) Тогда
		ДатаНачала = НачалоГода(ТекущаяДатаСеанса());
	КонецЕсли;
	
	Если не ЗначениеЗаполнено(ДатаОкончания) Тогда
		ДатаОкончания = КонецДня(ТекущаяДатаСеанса());
	КонецЕсли;
	
	Данные = ПолучитьТаблицуПлатёжнойИстории(ДатаОкончания, Контрагенты,Данныерасшифровки);
	
	ВнешниеНаборыДанных = Новый Структура;
	ВнешниеНаборыДанных.Вставить("ТаблицаНабораДанных", Данные);
	
	КомпоновщикМакета = новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, КомпоновщикНастроек.Настройки,Данныерасшифровки);
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, ВнешниеНаборыДанных,Данныерасшифровки, Истина);
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
КонецПроцедуры

Функция ПолучитьПредыдущиеСезоны(Сезон)
	
	запрос = новый Запрос(
	"ВЫБРАТЬ
	|	w_Сезоны.Ссылка КАК Ссылка,
	|	w_Сезоны.Код КАК Код,
	|	w_Сезоны.гф_Год КАК Год,
	|	w_Сезоны.гф_Номер КАК Номер
	|ИЗ
	|	Справочник.КоллекцииНоменклатуры КАК w_Сезоны
	|ГДЕ
	|	НЕ w_Сезоны.ПометкаУдаления
	|
	|УПОРЯДОЧИТЬ ПО
	|	Год УБЫВ,
	|	Номер УБЫВ
	|АВТОУПОРЯДОЧИВАНИЕ");
	
	выборка = запрос.Выполнить().Выбрать();
	
	пустое = Справочники.КоллекцииНоменклатуры.ПустаяСсылка();
	рез = новый Структура("Сезон1, Сезон2, Сезон3, Сезон4", пустое, пустое, пустое, пустое);
	Если выборка.НайтиСледующий(новый Структура("Ссылка", Сезон)) Тогда
		Для а=1 По 4 Цикл
			выборка.Следующий();
			рез["Сезон" + а] = выборка.Ссылка;
		КонецЦикла;
	КонецЕсли;
	
	возврат рез;
КонецФункции // ПолучитьПредыдущиеСезоны()

Функция ПолучитьТаблицуПлатёжнойИстории(ДатаОкончания, Контрагенты,Данныерасшифровки)
	
	Аналитика = новый СписокЗначений;
	Аналитика.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Контрагенты);
	Аналитика.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Договоры);
	
	СхемаКомпоновкиИстории = ПолучитьМакет("ПлатёжнаяИстория");
	КомпоновщикИстории = новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикИстории.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаКомпоновкиИстории));
	КомпоновщикИстории.ЗагрузитьНастройки(СхемаКомпоновкиИстории.НастройкиПоУмолчанию);
	
	
	ПараметрыДанных = КомпоновщикИстории.Настройки.ПараметрыДанных;
	//ПараметрыДанных.УстановитьЗначениеПараметра("Аналитика", Аналитика);
	ПараметрыДанных.УстановитьЗначениеПараметра("СчетаУчёта", ПланыСчетов.Хозрасчетный.РасчетыСПокупателямиИЗаказчиками);
	ПараметрыДанных.УстановитьЗначениеПараметра("ДатаНачала", ДатаНачала);
	ПараметрыДанных.УстановитьЗначениеПараметра("ДатаОкончания", КонецДня(ДатаОкончания));
	
	Данные = Новый ТаблицаЗначений;
	Данные.Колонки.Добавить("Партнер");
	Данные.Колонки.Добавить("ОплатаМин", новый ОписаниеТипов("Число"));
	Данные.Колонки.Добавить("ОплатаСредневзвешенное", новый ОписаниеТипов("Число"));
	
	ПараметрСезон = КомпоновщикНастроек.ПолучитьНастройки().ПараметрыДанных.Элементы.Найти("Сезон"); 
	Если ТипЗнч(Контрагенты)=Тип("СписокЗначений") Тогда			
			КомпоновщикИстории.Настройки.Отбор.Элементы.Очистить();
			отбор = КомпоновщикИстории.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
			отбор.Использование = Истина;
			отбор.ВидСравнения = ВидСравненияКомпоновкиДанных.ВСписке;
			отбор.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Партнер");
			отбор.ПравоеЗначение = Контрагенты;
			
			Если ПараметрСезон.Использование Тогда
				отбор = КомпоновщикИстории.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
				отбор.Использование = Истина;
				отбор.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
				отбор.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Сезон");
				отбор.ПравоеЗначение = ПараметрСезон.Значение;
			КонецЕсли;
			ОтборНастройки = КомпоновщикНастроек.Настройки.Отбор;
			ЭлементыПользовательскиеНастройки = КомпоновщикНастроек.ПользовательскиеНастройки.Элементы;  
			ОтборПоОрганизации = Неопределено;
			ПолеКомпоновкиОрганизация = Новый ПолеКомпоновкиДанных("Организация");  
			Для каждого ЭлементОтбора Из ОтборНастройки.Элементы Цикл
				Если ТипЗнч(ЭлементОтбора) = Тип("ЭлементОтбораКомпоновкиДанных")
					и ЭлементОтбора.ЛевоеЗначение = ПолеКомпоновкиОрганизация Тогда
					ОтборПоОрганизации = ЭлементОтбора;
					Прервать;
				КонецЕсли;	
			КонецЦикла; 
			Если ЭлементыПользовательскиеНастройки.Найти(ОтборПоОрганизации.ИдентификаторПользовательскойНастройки).Использование  Тогда
				Если ОтборПоОрганизации = Неопределено  Тогда
					ОтборПоОрганизации = ОтборНастройки.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
					ОтборПоОрганизации.ЛевоеЗначение = ПолеКомпоновкиОрганизация;
					ОтборПоОрганизации.РежимОтображения = РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Обычный; 
					ОтборПоОрганизации.ВидСравнения=ВидСравненияКомпоновкиДанных.Равно;
					ОтборПоОрганизации.ПравоеЗначение = ЭлементыПользовательскиеНастройки.Найти(ОтборПоОрганизации.ИдентификаторПользовательскойНастройки).ПравоеЗначение;	
				Иначе
					ОтборПоОрганизации.ПравоеЗначение = ЭлементыПользовательскиеНастройки.Найти(ОтборПоОрганизации.ИдентификаторПользовательскойНастройки).ПравоеЗначение;
					ОтборПоОрганизации.Использование=Истина;
				КонецЕсли;
			Иначе  
				ОтборПоОрганизации.Использование=Ложь;
			КонецЕсли;

			КомпоновщикМакета = новый КомпоновщикМакетаКомпоновкиДанных;
			МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиИстории, КомпоновщикИстории.Настройки,Данныерасшифровки,, Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
			ПроцессорКомпоновки = новый ПроцессорКомпоновкиДанных;
			ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,,Данныерасшифровки);
			ПроцессорВывода = новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
			таб = ПроцессорВывода.Вывести(ПроцессорКомпоновки);
			
			Если таб.Количество() > 0 Тогда
				запрос = новый Запрос(
				"ВЫБРАТЬ
				|	а.ДатаДок КАК ДатаДок,
				|	а.Договор КАК Договор,
				|	а.Документ КАК Документ,
				|	а.Партнер КАК Партнер,
				|	ЕСТЬNULL(а.ОборотДт, 0) КАК ОборотДт,
				|	ЕСТЬNULL(а.ОборотКт, 0) КАК ОборотКт,
				|	а.Организация КАК Организация,
				|	ЕСТЬNULL(а.ЧислоДнейЗадолженности, 0) КАК ЧислоДнейЗадолженности,
				|	а.ДатаКор КАК ДатаКор,
				|	а.ДатаМин КАК ДатаМин,
				|	ЕСТЬNULL(а.Сальдо, 0) КАК Сальдо,
				|	ЕСТЬNULL(а.КоличествоДней, 0) КАК КоличествоДней,
				|	ЕСТЬNULL(а.СальдоКД, 0) КАК СальдоКД
				|ПОМЕСТИТЬ таб
				|ИЗ
				|	&таб КАК а
				|ГДЕ
				|	а.ДатаМин МЕЖДУ &ДатаНачала И &ДатаОкончания
				|	И а.ДатаКор <= &ДатаОкончания
				|;
				|
				|////////////////////////////////////////////////////////////////////////////////
				|ВЫБРАТЬ
				|	а.Партнер КАК Партнер,
				|	СУММА(а.ОборотДт) КАК SalesTotal,
				|	СРЕДНЕЕ(а.Сальдо) КАК SaldoAverage,
				|	МИНИМУМ(а.Сальдо) КАК SaldoMin,
				|	ВЫБОР
				|		КОГДА СУММА(а.КоличествоДней) = 0
				|			ТОГДА 0
				|		ИНАЧЕ СУММА(а.СальдоКД) / СУММА(а.КоличествоДней)
				|	КОНЕЦ КАК SaldoWeightedAverage,
				|	ВЫБОР
				|		КОГДА СУММА(а.ОборотДт) = 0
				|			ТОГДА 0
				|		ИНАЧЕ 100 * СРЕДНЕЕ(а.Сальдо) / СУММА(а.ОборотДт)
				|	КОНЕЦ КАК PaymentRateAverage,
				|	ВЫБОР
				|		КОГДА СУММА(а.ОборотДт) = 0
				|			ТОГДА 0
				|		ИНАЧЕ 100 * МИНИМУМ(а.Сальдо) / СУММА(а.ОборотДт)
				|	КОНЕЦ КАК ОплатаМин,
				|	ВЫБОР
				|		КОГДА СУММА(а.КоличествоДней) = 0
				|				ИЛИ СУММА(а.ОборотДт) = 0
				|			ТОГДА 0
				|		ИНАЧЕ 100 * СУММА(а.СальдоКД) / СУММА(а.КоличествоДней) / СУММА(а.ОборотДт)
				|	КОНЕЦ КАК ОплатаСредневзвешенное
				|ИЗ
				|	таб КАК а
				|
				|СГРУППИРОВАТЬ ПО
				|	а.Партнер");
				
				Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
				Запрос.УстановитьПараметр("ДатаОкончания", КонецДня(ДатаОкончания));
				Запрос.УстановитьПараметр("Таб", таб);
				Выборка = Запрос.Выполнить().Выбрать();
				Пока Выборка.Следующий() Цикл
					ЗаполнитьЗначенияСвойств(Данные.Добавить(), Выборка);
				КонецЦикла;
			КонецЕсли;
	Иначе 
		КомпоновщикИстории.Настройки.Отбор.Элементы.Очистить();
		отбор = КомпоновщикИстории.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		отбор.Использование = Истина;
		отбор.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		отбор.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Партнер");
		отбор.ПравоеЗначение = Контрагенты;
		
		Если ПараметрСезон.Использование Тогда
			отбор = КомпоновщикИстории.Настройки.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
			отбор.Использование = Истина;
			отбор.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
			отбор.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Сезон");
			отбор.ПравоеЗначение = ПараметрСезон.Значение;
		КонецЕсли;
		
		КомпоновщикМакета = новый КомпоновщикМакетаКомпоновкиДанных;
		МакетКомпоновки = КомпоновщикМакета.Выполнить(СхемаКомпоновкиИстории, КомпоновщикИстории.Настройки,Данныерасшифровки,, Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
		ПроцессорКомпоновки = новый ПроцессорКомпоновкиДанных;
		ПроцессорКомпоновки.Инициализировать(МакетКомпоновки,,Данныерасшифровки);
		ПроцессорВывода = новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
		таб = ПроцессорВывода.Вывести(ПроцессорКомпоновки);
		
		Если таб.Количество() > 0 Тогда
			запрос = новый Запрос(
			"ВЫБРАТЬ
			|	а.ДатаДок КАК ДатаДок,
			|	а.Договор КАК Договор,
			|	а.Документ КАК Документ,
			|	а.Партнер КАК Партнер,
			|	ЕСТЬNULL(а.ОборотДт, 0) КАК ОборотДт,
			|	ЕСТЬNULL(а.ОборотКт, 0) КАК ОборотКт,
			|	а.Организация КАК Организация,
			|	ЕСТЬNULL(а.ЧислоДнейЗадолженности, 0) КАК ЧислоДнейЗадолженности,
			|	а.ДатаКор КАК ДатаКор,
			|	а.ДатаМин КАК ДатаМин,
			|	ЕСТЬNULL(а.Сальдо, 0) КАК Сальдо,
			|	ЕСТЬNULL(а.КоличествоДней, 0) КАК КоличествоДней,
			|	ЕСТЬNULL(а.СальдоКД, 0) КАК СальдоКД
			|ПОМЕСТИТЬ таб
			|ИЗ
			|	&таб КАК а
			|ГДЕ
			|	а.ДатаМин МЕЖДУ &ДатаНачала И &ДатаОкончания
			|	И а.ДатаКор <= &ДатаОкончания
			|;
			|
			|////////////////////////////////////////////////////////////////////////////////
			|ВЫБРАТЬ
			|	а.Партнер КАК Партнер,
			|	СУММА(а.ОборотДт) КАК SalesTotal,
			|	СРЕДНЕЕ(а.Сальдо) КАК SaldoAverage,
			|	МИНИМУМ(а.Сальдо) КАК SaldoMin,
			|	ВЫБОР
			|		КОГДА СУММА(а.КоличествоДней) = 0
			|			ТОГДА 0
			|		ИНАЧЕ СУММА(а.СальдоКД) / СУММА(а.КоличествоДней)
			|	КОНЕЦ КАК SaldoWeightedAverage,
			|	ВЫБОР
			|		КОГДА СУММА(а.ОборотДт) = 0
			|			ТОГДА 0
			|		ИНАЧЕ 100 * СРЕДНЕЕ(а.Сальдо) / СУММА(а.ОборотДт)
			|	КОНЕЦ КАК PaymentRateAverage,
			|	ВЫБОР
			|		КОГДА СУММА(а.ОборотДт) = 0
			|			ТОГДА 0
			|		ИНАЧЕ 100 * МИНИМУМ(а.Сальдо) / СУММА(а.ОборотДт)
			|	КОНЕЦ КАК ОплатаМин,
			|	ВЫБОР
			|		КОГДА СУММА(а.КоличествоДней) = 0
			|				ИЛИ СУММА(а.ОборотДт) = 0
			|			ТОГДА 0
			|		ИНАЧЕ 100 * СУММА(а.СальдоКД) / СУММА(а.КоличествоДней) / СУММА(а.ОборотДт)
			|	КОНЕЦ КАК ОплатаСредневзвешенное
			|ИЗ
			|	таб КАК а
			|
			|СГРУППИРОВАТЬ ПО
			|	а.Партнер");
			
			Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
			Запрос.УстановитьПараметр("ДатаОкончания", КонецДня(ДатаОкончания));
			Запрос.УстановитьПараметр("Таб", таб);
			Выборка = Запрос.Выполнить().Выбрать();
			Пока Выборка.Следующий() Цикл
				ЗаполнитьЗначенияСвойств(Данные.Добавить(), Выборка);
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
	возврат Данные;
	
КонецФункции // ПолучитьТаблицуПлатёжнойИстории()
