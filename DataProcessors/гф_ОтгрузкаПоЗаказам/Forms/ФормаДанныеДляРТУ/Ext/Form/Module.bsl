﻿
#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("ПрименятьНаценки", Объект.ПрименятьНаценки);
	Параметры.Свойство("РасчетЦен", РасчетЦен);
	
	Элементы.Наценки.Видимость = Объект.ПрименятьНаценки;
	
	ДатаДляРТУ = ТекущаяДатаСеанса();
	ЦифровойКодВалюты = "978";
	КурсЕвро = ПолучитьКурсЕвро(ДатаДляРТУ, ЦифровойКодВалюты); 
	
// ++ Окунев 17.01.2024	
	Для Каждого ЭлементМассива Из Параметры.МассивЗаказы Цикл
		
		НоваяСтрока = ВходящиеДанные.Добавить();
		
		ЗаполнитьЗначенияСвойств(НоваяСтрока, ЭлементМассива);
		
	КонецЦикла;	 
// -- Окунев 17.01.2024	
	
	ЗаполнитьТЧСкидкиПоЗаказам();
	ЗаполнитьТЧСкидки();
	ЗаполнитьТЧНаценки(); 
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТЧСкидкиПоЗаказам()
// ++ Окунев 17.01.2024	     

	Объект.СкидкиПоЗаказам.Очистить();
	
	Таб = ВходящиеДанные.Выгрузить();
	
	Цены = Таб.Скопировать(,"ВидЦены, Номенклатура");
	
	Цены.Свернуть("ВидЦены,Номенклатура");
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	Т.ВидЦены КАК ВидЦены,
	               |	Т.Номенклатура КАК Номенклатура
	               |ПОМЕСТИТЬ ВТ_ВидыЦен
	               |ИЗ
	               |	&Таб КАК Т
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ЦеныНоменклатуры25СрезПоследних.ВидЦены КАК ВидЦены,
	               |	ЦеныНоменклатуры25СрезПоследних.Номенклатура КАК Номенклатура,
	               |	ЦеныНоменклатуры25СрезПоследних.Цена КАК Цена
	               |ИЗ
	               |	РегистрСведений.ЦеныНоменклатуры25.СрезПоследних(
	               |			&ДатаЦен,
	               |			(ВидЦены, Номенклатура) В
	               |				(ВЫБРАТЬ
	               |					Т.ВидЦены,
	               |					Т.Номенклатура
	               |				ИЗ
	               |					ВТ_ВидыЦен КАК Т)) КАК ЦеныНоменклатуры25СрезПоследних
	               |ГДЕ
	               |	ЦеныНоменклатуры25СрезПоследних.ВидЦены <> ЗНАЧЕНИЕ(Справочник.ВидыЦен.ПустаяСсылка)";
	
	Запрос.Параметры.Вставить("Таб", 		Цены);	
	Запрос.Параметры.Вставить("ДатаЦен",	ДатаДляРТУ);	
	
	Результат = Запрос.Выполнить();
	
	// ++ Галфинд ВолковЕВ 2024/04/05
	Сто = 100;
	Один = 1;
	
	Если Параметры.Свойство("ТоварыВКоробках", Истина) И Результат.Пустой() Тогда
		
		ТЗ = Новый ТаблицаЗначений;
		ТЗ.Колонки.Добавить("Заказ");
		ТЗ.Колонки.Добавить("Скидка");
		ТЗ.Колонки.Добавить("Сумма");
		
		Для Каждого Строка Из Таб Цикл
			
			нс = ТЗ.Добавить();
			нс.Заказ		= Строка.Заказ;  
			нс.Скидка		= Строка.Скидка;
			
			Если Строка.Заказ.ЦенаВключаетНДС Тогда
				нс.Сумма = Строка.Цена * Строка.Количество;
			Иначе
				нс.Сумма = Строка.Цена * Строка.Количество * (Один + Строка.СтавкаНДС / Сто);
			КонецЕсли;
			
		КонецЦикла;
		
		ТЗ.Свернуть("Заказ, Скидка", "Сумма");
		
		Для Каждого Строка Из ТЗ Цикл
			
			нс = Объект.СкидкиПоЗаказам.Добавить();
			
			нс.Заказ			= Строка.Заказ;  
			нс.РучнаяСкидка		= Строка.Скидка;
			нс.СуммаБезСкидки	= Строка.Сумма;
			
		КонецЦикла;
		
	ИначеЕсли Параметры.Свойство("ТоварыВКоробках", Истина) И Не Результат.Пустой() Тогда
		
		Если Не Результат.Пустой() Тогда 
			
			Выборка = Результат.Выбрать();
			
			Пока Выборка.Следующий() Цикл
				
				Отбор = Новый Структура;
				
				Отбор.Вставить("ВидЦены",		Выборка.ВидЦены);
				Отбор.Вставить("Номенклатура",	Выборка.Номенклатура);
				
				Строки = Таб.НайтиСтроки(Отбор);   
				
				Для Каждого Строка Из Строки Цикл
					
					Строка.Цена = Выборка.Цена;
					
				КонецЦикла;	
				
			КонецЦикла;	
			
		КонецЕсли;
		
		Для Каждого Строка Из Таб Цикл
			
			Если Строка.Заказ.ЦенаВключаетНДС Тогда
				Строка.Сумма = Строка.Цена * Строка.Количество;
			Иначе
				Строка.Сумма = Строка.Цена * Строка.Количество * (Один + Строка.СтавкаНДС / Сто);
			КонецЕсли;
			
		КонецЦикла;	 
		
		Таб.Свернуть("Заказ, Скидка", "Сумма");
		
		Для Каждого Строка Из Таб Цикл
			
			нс = Объект.СкидкиПоЗаказам.Добавить();
			
			нс.Заказ			= Строка.Заказ;  
			нс.РучнаяСкидка		= Строка.Скидка;
			нс.СуммаБезСкидки	= Строка.Сумма;
			
		КонецЦикла;
		
	Иначе
	// ++ Галфинд ВолковЕВ 2024/04/05	
		
	Если Не Результат.Пустой() Тогда 
		
		Выборка = Результат.Выбрать();
		
		Пока Выборка.Следующий() Цикл
			
			Отбор = Новый Структура;
			
			Отбор.Вставить("ВидЦены",		Выборка.ВидЦены);
			Отбор.Вставить("Номенклатура",	Выборка.Номенклатура);
			
			Строки = Таб.НайтиСтроки(Отбор);   
			
			Для Каждого Строка Из Строки Цикл
				
				Строка.Цена = Выборка.Цена;
				
			КонецЦикла;	
			
		КонецЦикла;	
		
	КонецЕсли;    
	
	Сто = 100;
	
	Для Каждого Строка Из Таб Цикл
		
		Строка.Сумма = (Строка.Количество * Строка.Цена) * (Сто + Строка.СтавкаНДС) / Сто;
		
	КонецЦикла;	 
	
	Таб.Свернуть("Заказ, Скидка", "Сумма");
	
	Для Каждого Строка Из Таб Цикл
		
		нс = Объект.СкидкиПоЗаказам.Добавить();
		
		нс.Заказ			= Строка.Заказ;  
		нс.РучнаяСкидка		= Строка.Скидка;
		нс.СуммаБезСкидки	= Строка.Сумма;
		
	КонецЦикла;
	
    // ++ Галфинд ВолковЕВ 2024/04/05	
	КонецЕсли;
    // -- Галфинд ВолковЕВ 2024/04/05


// -- Окунев 17.01.2024	

	Для Каждого нс Из Объект.СкидкиПоЗаказам Цикл
		Если ЗначениеЗаполнено(нс.Заказ.Склад) Тогда
			нс.КоробнойСклад = ЭтоТоварыВКоробах(нс.Заказ.Склад);
		КонецЕсли;
		нс.СезонныйЗаказ = нс.Заказ.гф_СезонныйЗаказ;
		нс.КоличествоДнейОтсрочкиПлатежа = НайтиКоличествоДнейОтсрочкиПлатежа(нс.Заказ.Договор);
		мКоличествоДнейОтсрочкиПлатежа = нс.КоличествоДнейОтсрочкиПлатежа;
		мОрганизация = нс.Заказ.Организация;
		мКонтрагент = нс.Заказ.Контрагент;
		мДоговор = нс.Заказ.Договор;
		мСезонныйЗаказ = нс.Заказ.гф_СезонныйЗаказ;
	КонецЦикла;
	Объект.СкидкиПоЗаказам.Сортировать("Заказ");
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТЧСкидки()
	ТаблицаСкидок = Новый ТаблицаЗначений;
	ТаблицаСкидок.Колонки.Добавить("ВидСкидки");
	ТаблицаСкидок.Колонки.Добавить("Порядок");
	
	// добавляем скидки из регистра гф_ДопустимыеЗначенияСкидок
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	гф_ДопустимыеЗначенияСкидок.ВидСкидки КАК ВидСкидки
	               |ИЗ
	               |	РегистрСведений.гф_ДопустимыеЗначенияСкидок КАК гф_ДопустимыеЗначенияСкидок
	               |ГДЕ
	               |	гф_ДопустимыеЗначенияСкидок.ИспользоватьДляРТУ
	               |	И НЕ гф_ДопустимыеЗначенияСкидок.ВидСкидки В(&ВидыСкидок)";
	Запрос.УстановитьПараметр("ВидыСкидок", Объект.Скидки.Выгрузить().ВыгрузитьКолонку("ВидСкидки"));
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		Если ТаблицаСкидок.Найти(Выборка.ВидСкидки, "ВидСкидки") = Неопределено Тогда
			СтрокаСкидки = ТаблицаСкидок.Добавить();
			СтрокаСкидки.ВидСкидки = Выборка.ВидСкидки;
			СтрокаСкидки.Порядок = ?(СтрокаСкидки.ВидСкидки = Перечисления.гф_ВидыСкидок.СкидкаЗаПредоплату, 0, 1);
		КонецЕсли;
	КонецЦикла;
	ТаблицаСкидок.Сортировать("Порядок");
	
	СкидкаЗаПредоплату = 0;
	Для Каждого СтрокаСкидки Из ТаблицаСкидок Цикл
		СтруктураПоиска = Новый Структура("ВидСкидки", СтрокаСкидки.ВидСкидки);
		СтрокиПоЗаказу = Объект.Скидки.НайтиСтроки(СтруктураПоиска);
		Если СтрокиПоЗаказу.Количество() = 0 Тогда
			нс = Объект.Скидки.Добавить();
			нс.ВидСкидки = СтрокаСкидки.ВидСкидки;
			нс.СкидкаРасчетная = ПолучитьРасчетнуюСкидкуПоЗаказу(нс.ВидСкидки, ДатаДляРТУ, КурсЕвро, СкидкаЗаПредоплату);
			нс.СкидкаДляРТУ = нс.СкидкаРасчетная;
			нс.СкидкаПоРегистру = ПолучитьСкидкуПоРегистру(нс.ВидСкидки, ДатаДляРТУ);
		КонецЕсли;
	КонецЦикла;
	Объект.Скидки.Сортировать("ВидСкидки");
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТЧНаценки()

	Объект.Наценки.Очистить();
	
	Если Объект.ПрименятьНаценки Тогда    
		
		Запрос = Новый Запрос;
		
		Запрос.Текст = "ВЫБРАТЬ
		|	гф_НаценкиЗаКурсСрезПоследних.КурсДо КАК КурсДо,
		|	гф_НаценкиЗаКурсСрезПоследних.ПроцентНаценки КАК ПроцентНаценки
		|ПОМЕСТИТЬ ВТ_Наценки
		|ИЗ
		|	РегистрСведений.гф_НаценкиЗаКурс.СрезПоследних(
		|			&ДатаДляРТУ,
		|			Сезон = &Сезон
		|				И КурсДо >= &КурсДо) КАК гф_НаценкиЗаКурсСрезПоследних
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	МИНИМУМ(ВТ_Наценки.КурсДо) КАК КурсДо
		|ПОМЕСТИТЬ ВТ_Курс
		|ИЗ
		|	ВТ_Наценки КАК ВТ_Наценки
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|	ВТ_Курс.КурсДо КАК КурсДо,
		|	ВТ_Наценки.ПроцентНаценки КАК ПроцентНаценки
		|ИЗ
		|	ВТ_Курс КАК ВТ_Курс
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Наценки КАК ВТ_Наценки
		|		ПО ВТ_Курс.КурсДо = ВТ_Наценки.КурсДо";    
		
		мКурсЕвро = Окр(КурсЕвро * 2) / 2;
		
		Запрос.Параметры.Вставить("КурсДо",		мКурсЕвро);
		Запрос.Параметры.Вставить("ДатаДляРТУ",	ДатаДляРТУ);
		Запрос.Параметры.Вставить("Сезон",		мДоговор.гф_Сезон);
		
		Результат = Запрос.Выполнить();
		
		Если Результат.Пустой() Тогда 
			
			ПроцентНаценки = 0;
			
		Иначе
			
			Выборка = Результат.Выбрать();
			
			Выборка.Следующий();
			
			ПроцентНаценки = Выборка.ПроцентНаценки;
			
		КонецЕсли;	
		
		НоваяСтрока = Объект.Наценки.Добавить();
		
		НоваяСтрока.ВидНаценки			= "Наценка за курс";
		НоваяСтрока.НаценкаРасчетная	= ПроцентНаценки;
		НоваяСтрока.НаценкаДляРТУ		= ПроцентНаценки;
		
	КонецЕсли;	
	
КонецПроцедуры

&НаСервере
Процедура ВыполнитьРасчетИтогов(Заказ)
	Если Не ЗначениеЗаполнено(Заказ) Тогда
		Возврат;
	КонецЕсли;
	ИтогРасчетнаяСкидка = 0;
	ИтогСкидкаДляРТУ = 0;
	ИтогСкидкаПоРегистру = 0;
	Для Каждого СтрокаТЧ Из Объект.Скидки Цикл
		Если СтрокаТЧ.Заказ <> Заказ Тогда
			Продолжить;
		КонецЕсли;
		// суммирую колонку Скидку расчетную
		ИтогРасчетнаяСкидка = ИтогРасчетнаяСкидка + СтрокаТЧ.СкидкаРасчетная;
		// суммирую колонку Скидку для РТУ
		ИтогСкидкаДляРТУ = ИтогСкидкаДляРТУ + СтрокаТЧ.СкидкаДляРТУ;
		// суммирую колонку Скидку по регистру
		ИтогСкидкаПоРегистру = ИтогСкидкаПоРегистру + СтрокаТЧ.СкидкаПоРегистру;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура РассчитатьСкидкуДляРТУ()  

	ЗначениеСто			= 100;
	НаценкаЗаКурс		= 0;   
	
	Если Объект.ПрименятьНаценки И Объект.Наценки.Количество() Тогда	
		
		НаценкаЗаКурс = Объект.Наценки[0].НаценкаДляРТУ; 	
		
	КонецЕсли;	
	
	Для Каждого СтрокаТЧ Из Объект.СкидкиПоЗаказам Цикл 
		
		Скидки = ПолучитьСписокСкидок(СтрокаТЧ);
		
		СкидкаКоэффициент = 1;
		// ++ Галфинд ВолковЕВ 2024/05/03
		//Для Каждого Элемент Из Скидки Цикл
		//	
		//	ТекушаяСкидкаКоэффициент = (ЗначениеСто - Элемент.Значение) / ЗначениеСто; 
		//	СкидкаКоэффициент =  СкидкаКоэффициент * ТекушаяСкидкаКоэффициент;
		//	
		//КонецЦикла;
		СуммаЗначенийСкидок = 0;
		
		Для Каждого Элемент Из Скидки Цикл
			
			СуммаЗначенийСкидок = СуммаЗначенийСкидок + Элемент.Значение;
			
		КонецЦикла;
		
		СкидкаКоэффициент = (ЗначениеСто - СуммаЗначенийСкидок) / ЗначениеСто;
		// -- Галфинд ВолковЕВ 2024/05/03

		СтрокаТЧ.СкидкаДляРТУ = ЗначениеСто - (СкидкаКоэффициент * ЗначениеСто);
		СтрокаТЧ.НаценкаДляРТУ = НаценкаЗаКурс; 
		
		РучнаяСкидкаКоэффициент = (ЗначениеСто - СтрокаТЧ.РучнаяСкидка) / ЗначениеСто; 
		НаценкаКоэффициент = (ЗначениеСто + НаценкаЗаКурс) / ЗначениеСто; 
		
		// Вариант: прибавляем наценку
		СтрокаТЧ.ИтоговаяСкидкаДляРТУ =  ЗначениеСто - (РучнаяСкидкаКоэффициент * СкидкаКоэффициент * ЗначениеСто) - СтрокаТЧ.НаценкаДляРТУ;
		
		// Вариант: умножаем на коэффициент наценки
		СтрокаТЧ.ИтоговаяСкидкаДляРТУ =  ЗначениеСто - (РучнаяСкидкаКоэффициент * СкидкаКоэффициент * НаценкаКоэффициент * ЗначениеСто);
		
		СтрокаТЧ.Сумма = СтрокаТЧ.СуммаБезСкидки * (ЗначениеСто - СтрокаТЧ.ИтоговаяСкидкаДляРТУ) / ЗначениеСто;
		
	КонецЦикла;
	
КонецПроцедуры

Функция СписокСкидокПоПрайсЛисту(Заказ)
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Ссылка",			Заказ);
	Запрос.УстановитьПараметр("Контрагент",		Заказ.Контрагент);
	Запрос.УстановитьПараметр("Организация",	Заказ.Организация);
	Запрос.УстановитьПараметр("Договор",		Заказ.Договор);
	Запрос.УстановитьПараметр("Дата",			ДатаДляРТУ);
	
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	               |	гф_ГлобальныеЗначенияСписок.Значение КАК Скидка
	               |ПОМЕСТИТЬ ВТ_Скидки
	               |ИЗ
	               |	ПланВидовХарактеристик.гф_ГлобальныеЗначения КАК гф_ГлобальныеЗначения
	               |		ЛЕВОЕ СОЕДИНЕНИЕ ПланВидовХарактеристик.гф_ГлобальныеЗначения.Список КАК гф_ГлобальныеЗначенияСписок
	               |		ПО гф_ГлобальныеЗначения.Ссылка = гф_ГлобальныеЗначенияСписок.Ссылка
	               |ГДЕ
	               |	гф_ГлобальныеЗначения.Ключ = ""гф_ГлобальныеЗначенияСкидкиДляЗаказаКлиента""
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	гф_ИсторияИзмененияСкидокСрезПоследних.ВидСкидки КАК ВидСкидки,
	               |	гф_ИсторияИзмененияСкидокСрезПоследних.Скидка КАК Скидка
	               |ИЗ
	               |	РегистрСведений.гф_ИсторияИзмененияСкидок.СрезПоследних(
	               |			&Дата,
	               |			Организация = &Организация
	               |				И Контрагент = &Контрагент
	               |				И Договор = &Договор) КАК гф_ИсторияИзмененияСкидокСрезПоследних
	               |ГДЕ
	               |	гф_ИсторияИзмененияСкидокСрезПоследних.ВидСкидки В
	               |			(ВЫБРАТЬ
	               |				Т.Скидка
	               |			ИЗ
	               |				ВТ_Скидки КАК Т)";
	
	Результат = Запрос.Выполнить();
	
	СписокСкидок = Новый СписокЗначений;
	
	Если Не Результат.Пустой() Тогда
		
		Выборка = Результат.Выбрать();
		
		Пока Выборка.Следующий() Цикл
			
			СписокСкидок.Добавить(Выборка.Скидка, Выборка.ВидСкидки);
			
		КонецЦикла;	
		
	КонецЕсли;
	
	Возврат СписокСкидок;
	
КонецФункции

&НаСервере
Процедура СохранитьСкидкуДляРТУпоЗаказу(Заказ)
	СтруктураПоиска = Новый Структура("Заказ", Заказ);
	СтрокиЗаказа = Объект.СкидкиПоЗаказам.НайтиСтроки(СтруктураПоиска);
	Если СтрокиЗаказа.Количество() > 0 Тогда
		СтрокаЗаказа = СтрокиЗаказа[0];
		СтрокаЗаказа.СкидкаДляРТУ = ИтогСкидкаДляРТУ;
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЭтоТоварыВКоробах(Склад)
	Если Не ЗначениеЗаполнено(Склад) Тогда
		Возврат Ложь;
	КонецЕсли;
	ТоварыВКоробах = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("ИдентификаторДляФормул",
		"гф_СкладыТоварыВКоробах");
	
	ТоварыВКоробахЗначение = УправлениеСвойствами.ЗначениеСвойства(Склад, ТоварыВКоробах);	
	
	Если ЗначениеЗаполнено(ТоварыВКоробахЗначение) И ТоварыВКоробахЗначение = Истина Тогда
		 Возврат Истина;
	Иначе
		 Возврат Ложь;
	КонецЕсли;
КонецФункции

&НаСервереБезКонтекста
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

&НаСервере
Функция ПолучитьСкидкуПоРегистру(ВидСкидки, Период)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	гф_ИсторияИзмененияСкидокСрезПоследних.Скидка КАК Скидка
	               |ИЗ
	               |	РегистрСведений.гф_ИсторияИзмененияСкидок.СрезПоследних(
	               |			&Период,
	               |			ВидСкидки = &ВидСкидки
	               |				И Договор = &Договор
	               |				И Контрагент = &Контрагент
	               |				И Организация = &Организация) КАК гф_ИсторияИзмененияСкидокСрезПоследних";
	Запрос.УстановитьПараметр("Период", Период);
	Запрос.УстановитьПараметр("ВидСкидки", ВидСкидки);
	Запрос.УстановитьПараметр("Контрагент", мКонтрагент);
	Запрос.УстановитьПараметр("Договор", мДоговор);
	Запрос.УстановитьПараметр("Организация", мОрганизация);
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Если Выборка.Следующий() Тогда
		Возврат Выборка.Скидка;
	Иначе
		Возврат 0;
	КонецЕсли;
КонецФункции

&НаСервере
Функция ПолучитьРасчетнуюСкидкуПоЗаказуСезонныйЗаказ(ВидСкидки, Дата, КурсЕвро, СкидкаЗаПредоплату)
	
	// Сезонный заказ
	
	// Скидка за предоплату
	Если ВидСкидки = Перечисления.гф_ВидыСкидок.СкидкаЗаПредоплату Тогда
		СкидкаПоРегистру = ПолучитьСкидкуПоРегистру(ВидСкидки, Дата);
		Если СкидкаПоРегистру > 0 Тогда
			СкидкаЗаПредоплату = СкидкаПоРегистру;
			Возврат СкидкаПоРегистру;
		Иначе
			Возврат 0;
		КонецЕсли;
	КонецЕсли;
	
	// Скидка за курс
	ЗначениеСемьдесят = 70;
	Если	ВидСкидки = Перечисления.гф_ВидыСкидок.СкидкаЗаКурс
		И	СкидкаЗаПредоплату <= 0
		И	КурсЕвро < ЗначениеСемьдесят Тогда
		СкидкаПоРегистру = ПолучитьСкидкуПоРегистру(ВидСкидки, Дата);
		Возврат СкидкаПоРегистру;
	Иначе
		Возврат 0;
	КонецЕсли;
	
	Возврат 0;
	
КонецФункции	

&НаСервере
Функция ПолучитьРасчетнуюСкидкуПоЗаказу(ВидСкидки, Дата, КурсЕвро, СкидкаЗаПредоплату)
	
	Если мКоличествоДнейОтсрочкиПлатежа > 0 Тогда
		Возврат 0;
	КонецЕсли;
		
	Если мСезонныйЗаказ Тогда
		// Сезонный заказ
		
		Возврат ПолучитьРасчетнуюСкидкуПоЗаказуСезонныйЗаказ(ВидСкидки, Дата, КурсЕвро, СкидкаЗаПредоплату);
		
	Иначе
		// НЕ Сезонный заказ
		
		// Скидка за курс
		ЗначениеСемьдесят = 70;
		Если	ВидСкидки = Перечисления.гф_ВидыСкидок.СкидкаЗаКурс
			И	КурсЕвро < ЗначениеСемьдесят Тогда
			СкидкаПоРегистру = ПолучитьСкидкуПоРегистру(ВидСкидки, Дата);
			Возврат СкидкаПоРегистру;
		Иначе
			Возврат 0;
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат 0;
	
КонецФункции

&НаСервере
Функция ПолучитьПроцентСкидкиПоЗаказу(Заказ) 
	
	Если РасчетЦен = 2 И Заказ.гф_СезонныйЗаказ Тогда   
		
		СписокСкидок = СписокСкидокПоПрайсЛисту(Заказ); 
		
		Результат = 0;
		
		Для Каждого Элемент Из СписокСкидок Цикл
			
			Результат = Результат + Элемент.Значение;
			
		КонецЦикла;	
		
		Возврат Результат;
		
	КонецЕсли;	
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Ссылка", Заказ);
	
	Запрос.Текст = "ВЫБРАТЬ
	|	МАКСИМУМ(ЗаказКлиентаТовары.ПроцентРучнойСкидки) КАК Скидка
	|ИЗ
	|	Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
	|ГДЕ
	|	ЗаказКлиентаТовары.Ссылка = &Ссылка";
	
	
	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		
		Возврат 0;
		
	КонецЕсли;
	
	Выборка = Результат.Выбрать();
	
	Выборка.Следующий();
		
	Возврат Выборка.Скидка;
	
КонецФункции

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ДанныеИзменены = Ложь;
	ЗаполнитьПроцентСкидки();
	РассчитатьСкидкуДляРТУ();
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПроцентСкидки() 
	ПроцентСкидкиМинимум = 0;
	ПроцентСкидкиМаксимум = 0;
	Для Каждого СтрокаТЗ Из Объект.СкидкиПоЗаказам Цикл
		СкидкаПоЗаказу = ПолучитьПроцентСкидкиПоЗаказу(СтрокаТЗ.Заказ);
		// Процент скидки минимум
		Если Не ЗначениеЗаполнено(ПроцентСкидкиМинимум) Тогда
			ПроцентСкидкиМинимум = СкидкаПоЗаказу;
		Иначе
			ПроцентСкидкиМинимум = ?(ПроцентСкидкиМинимум > СкидкаПоЗаказу, СкидкаПоЗаказу, ПроцентСкидкиМинимум);
		КонецЕсли;
		// Процент скидки максимум
		Если Не ЗначениеЗаполнено(ПроцентСкидкиМаксимум) Тогда
			ПроцентСкидкиМаксимум = СкидкаПоЗаказу;
		Иначе
			ПроцентСкидкиМаксимум = ?(ПроцентСкидкиМаксимум < СкидкаПоЗаказу, СкидкаПоЗаказу, ПроцентСкидкиМаксимум);
		КонецЕсли;
	КонецЦикла;
	Если ПроцентСкидкиМинимум <> ПроцентСкидкиМаксимум Тогда
		ПроцентСкидки = "" + Формат(ПроцентСкидкиМинимум, "ЧДЦ=2; ЧН=0,00") + " - " + Формат(ПроцентСкидкиМаксимум,
			"ЧДЦ=2; ЧН=0,00");
	Иначе
		ПроцентСкидки = "" + Формат(ПроцентСкидкиМинимум, "ЧДЦ=2; ЧН=0,00");
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьКурсЕвро(Дата, ЦифровойКодВалюты)
	Валюта = Справочники.Валюты.НайтиПоКоду(ЦифровойКодВалюты);
	СтруктураКурса = РаботаСКурсамиВалютУТ.ПолучитьКурсВалюты(Валюта, Дата);
	Возврат СтруктураКурса.КурсЧислитель;
КонецФункции

&НаКлиенте
Процедура ДатаДляРТУПриИзменении(Элемент)
	КурсЕвро = ПолучитьКурсЕвро(ДатаДляРТУ, ЦифровойКодВалюты);
	Объект.Скидки.Очистить();
	ЗаполнитьТЧСкидкиПоЗаказам();
	ЗаполнитьТЧСкидки();
	ЗаполнитьТЧНаценки();
	ЗаполнитьПроцентСкидки();
	РассчитатьСкидкуДляРТУ();
КонецПроцедуры

&НаКлиенте
Процедура СкидкиПоЗаказамЗаказНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
КонецПроцедуры

&НаСервере
Функция ЗаполнитьРезультат()
	
	Результат = Новый Массив;
	
	Для Каждого СтрокаТЧ Из Объект.СкидкиПоЗаказам Цикл  
		
		Если РасчетЦен = 2 И СтрокаТЧ.Заказ.гф_СезонныйЗаказ Тогда   
			
			РучнаяСкидка = СписокСкидокПоПрайсЛисту(СтрокаТЧ.Заказ);
			// ++ Галфинд ВолковЕВ 2024/05/03 Скидки по регистру получены и расчитаны на этапе работы со скидками и продолжения отгрузки 
			РучнаяСкидка = 0;
			// -- Галфинд ВолковЕВ 2024/05/03
			
		Иначе           
			
			РучнаяСкидка = 0;
			
		КонецЕсли;   
		
		Скидки = ПолучитьСписокСкидок(СтрокаТЧ);
		
		Наценки = Новый СписокЗначений;
		
		Если Объект.ПрименятьНаценки И Объект.Наценки.Количество() Тогда	
			
			Наценки.Добавить(Объект.Наценки[0].НаценкаДляРТУ, "Наценка на курс"); 	
			
		КонецЕсли;	  
		
		СкидкаПоЗаказу = Новый Структура;
		
		СкидкаПоЗаказу.Вставить("Заказ",		СтрокаТЧ.Заказ);
		СкидкаПоЗаказу.Вставить("ДатаДляРТУ",	ДатаДляРТУ);	
		СкидкаПоЗаказу.Вставить("РучнаяСкидка",	РучнаяСкидка);
		СкидкаПоЗаказу.Вставить("Скидки",		Скидки);
		СкидкаПоЗаказу.Вставить("Наценки",		Наценки);
		
		Результат.Добавить(СкидкаПоЗаказу);
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ПолучитьСписокСкидок(СтрокаТЧ)
	
	СкидкаЗаКурс		= 0;         
	СкидкаЗаПредоплату	= 0;
	
	Скидки = Новый СписокЗначений;
	
	Для Каждого СтрокаТЗ Из Объект.Скидки Цикл 
		
		// ++ Галфинд ВолковЕВ 2024/05/02 Вывод скидок по регистру в ТЧ окна по работе со скидками
		Если РасчетЦен = 2 И СтрокаТЗ.СкидкаПоРегистру > 0
			И ( СтрокаТЗ.ВидСкидки = ПредопределенноеЗначение("Перечисление.гф_ВидыСкидок.РекламационныйБонус")
			Или СтрокаТЗ.ВидСкидки = ПредопределенноеЗначение("Перечисление.гф_ВидыСкидок.СкидкаЗаОбъем") )
			Тогда
			
			СтрокаТЗ.СкидкаРасчетная 	= СтрокаТЗ.СкидкаПоРегистру;
			СтрокаТЗ.СкидкаДляРТУ 		= СтрокаТЗ.СкидкаПоРегистру;
			
		КонецЕсли;
		// -- Галфинд ВолковЕВ 2024/05/02
		
		Если СтрокаТЗ.ВидСкидки = ПредопределенноеЗначение("Перечисление.гф_ВидыСкидок.СкидкаЗаКурс") Тогда
			
			СкидкаЗаКурс = СтрокаТЗ.СкидкаДляРТУ;
			
		ИначеЕсли СтрокаТЗ.ВидСкидки = ПредопределенноеЗначение("Перечисление.гф_ВидыСкидок.СкидкаЗаПредоплату") Тогда
			
			СкидкаЗаПредоплату = СтрокаТЗ.СкидкаДляРТУ;
			
		Иначе
			
			Если СтрокаТЗ.СкидкаДляРТУ Тогда
				
				Скидки.Добавить(СтрокаТЗ.СкидкаДляРТУ, СтрокаТЗ.ВидСкидки);
				
			КонецЕсли; 	
			
		КонецЕсли;	
		
		// ++ Галфинд ВолковЕВ 2024/05/02 Перенесено выше и добавлена запись в расчет скидок в документ РТУ
		// // ++ Галфинд ВолковЕВ 2024/04/05
		// Если РасчетЦен = 2
		//	И СтрокаТЗ.ВидСкидки = ПредопределенноеЗначение("Перечисление.гф_ВидыСкидок.РекламационныйБонус")
		//	И СтрокаТЗ.СкидкаПоРегистру > 0 Тогда
		//	
		//	СтрокаТЗ.СкидкаРасчетная = СтрокаТЗ.СкидкаПоРегистру;
		//	
		// КонецЕсли;
		//
		// Если РасчетЦен = 2
		//	И СтрокаТЗ.ВидСкидки = ПредопределенноеЗначение("Перечисление.гф_ВидыСкидок.СкидкаЗаОбъем")
		//	И СтрокаТЗ.СкидкаПоРегистру > 0 Тогда
		//	
		//	СтрокаТЗ.СкидкаРасчетная = СтрокаТЗ.СкидкаПоРегистру;
		//	
		// КонецЕсли;
		// // -- Галфинд ВолковЕВ 2024/04/05
		// -- Галфинд ВолковЕВ 2024/05/02
		
	КонецЦикла;        
	
	Если СтрокаТЧ.КоличествоДнейОтсрочкиПлатежа = 0 Тогда
		
		Если СтрокаТЧ.СезонныйЗаказ Тогда
			
			мСкидкаЗаПредоплату = СкидкаЗаПредоплату; 
			
		Иначе	
			
			мСкидкаЗаПредоплату = 0;
			
		КонецЕсли; 
		
		Если КурсЕвро < 70 Тогда 
			
			мСкидкаЗаКурс = СкидкаЗаКурс;
			
		Иначе
			
			мСкидкаЗаКурс = 0;
			
		КонецЕсли;	
		
	Иначе	
		
		мСкидкаЗаПредоплату = 0;    
		
		мСкидкаЗаКурс = 0;
		
	КонецЕсли;
	
	Если мСкидкаЗаПредоплату Тогда
		
		Скидки.Добавить(мСкидкаЗаПредоплату, ПредопределенноеЗначение("Перечисление.гф_ВидыСкидок.СкидкаЗаПредоплату"));
		
	Иначе	
		
		Если мСкидкаЗаКурс Тогда			
			
			Скидки.Добавить(мСкидкаЗаКурс, ПредопределенноеЗначение("Перечисление.гф_ВидыСкидок.СкидкаЗаКурс"));
			
		КонецЕсли;
		
	КонецЕсли;	     
	
	
	Возврат Скидки;
	
КонецФункции

&НаКлиенте
Процедура СохранитьСкидкуДляРТУ(Команда)
	Для Каждого СтрокаТЧ Из Объект.СкидкиПоЗаказам Цикл
		СтрокаТЧ.СкидкаДляРТУ = мСкидкаДляРТУ;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Если ДанныеИзменены Тогда
		
		Сообщить("Данные не были записаны!");
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СкидкиСкидкаДляРТУПриИзменении(Элемент)
	РассчитатьСкидкуДляРТУ();
КонецПроцедуры

&НаКлиенте
Процедура НаценкиНаценкаДляРТУПриИзменении(Элемент)
	РассчитатьСкидкуДляРТУ();
КонецПроцедуры

&НаКлиенте
Процедура СкидкиПоЗаказамПриИзменении(Элемент)
	ДанныеИзменены = Истина;
КонецПроцедуры

&НаКлиенте
Процедура Записать(Команда)
	
	Результат = ЗаполнитьРезультат();

	ДанныеИзменены = Ложь;
	
	СтруктураВозврата = Новый Структура();
	
	СтруктураВозврата.Вставить("Действие", "ЗаписатьСкидкиПродолжить");
	СтруктураВозврата.Вставить("Результат", Результат);
	
	// ++ Галфинд ВолковЕВ 2024/04/05
	СуммаДляОрдера = ЗаполнитьИтоговуюСуммуДляОрдера();
	СтруктураВозврата.Вставить("гф_СуммаДляОрдера", СуммаДляОрдера);
	// -- Галфинд ВолковЕВ 2024/04/05
	
	Закрыть(СтруктураВозврата);
	
КонецПроцедуры

&НаСервере
Функция ЗаполнитьИтоговуюСуммуДляОрдера()
	
	// ++ Галфинд ВолковЕВ 2024/04/05
	МассивСуммаДляОрдера = Новый Массив();
	
	Для Каждого СтрокаТЧ Из Объект.СкидкиПоЗаказам Цикл  
		
		СтруктураСуммаДляОрдера = Новый Структура();
		СтруктураСуммаДляОрдера.Вставить("Заказ", СтрокаТЧ.Заказ);
		СтруктураСуммаДляОрдера.Вставить("Сумма", СтрокаТЧ.Сумма);
		
		// ++ Галфинд ВолковЕВ 2024/04/25
		// Передача адреса заказа, для сравнения строк с суммами при записи в реквизит "гф_СуммаДляОрдера" в расходном ордере
		Если ЗначениеЗаполнено(СтрокаТЧ.Заказ) И ЗначениеЗаполнено(СтрокаТЧ.Заказ.гф_АдресДоставки) Тогда
			СтруктураСуммаДляОрдера.Вставить("Адрес", СтрокаТЧ.Заказ.гф_АдресДоставки.НомерАдреса);
		КонецЕсли;
        // ++ Галфинд ВолковЕВ 2024/04/25
		
		МассивСуммаДляОрдера.Добавить(СтруктураСуммаДляОрдера);
				
	КонецЦикла;
	
	Возврат МассивСуммаДляОрдера;
	// -- Галфинд ВолковЕВ 2024/04/05
	
КонецФункции

#КонецОбласти
